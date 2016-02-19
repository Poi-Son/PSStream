//
//  PSStream.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

/**
 * 具有延迟计算的运算符
 * Cast，Concat，DefaultIfEmpty，Distinct，Except，GroupBy，GroupJoin，Intersect，
 * Join，OfType，OrderBy，OrderByDescending，Repeat，Reverse，Select，SelectMany，Skip，
 * SkipWhile，Take，TakeWhile，ThenBy，ThenByDescending，Union，Where，Zip
 *
 *
 * 立即执行的运算符
 * Aggregate，All，Any，Average，Contains，Count，ElementAt，ElementAtOrDefault，
 * Empty，First，FirstOrDefault，Last，LastOrDefault，LongCount，Max，Min，Range，
 * SequenceEqual，Single，SingleOrDefault，Sum，ToArray，ToDictionary，ToList，ToLookup
 */

@interface PSStream (){
    PSStreamAction *_actionChain;
}
@property (nonatomic, readonly) NSArray<PSStreamTuple *> *stream;
@property (nonatomic, readonly) PSStreamAction *actionChain;
@end

@implementation PSStream

- (instancetype)initWithDatasource:(NSArray *)datasource{
    if (self = [super init]) {
        _stream = datasource;
    }
    return self;
}

- (instancetype)_init{
    return self = [super init];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx{
    return self.stream[idx];
}

- (PSStreamAction *)actionChain{
    return _actionChain ?: (_actionChain = [PSStreamAction new]);
}

- (void)doAction:(void (^)(PSStreamTuple *tuple, BOOL *stop))action{
    self.actionChain.nextAction = [PSStreamAction new];
    NSMutableArray *new_stream = [NSMutableArray new];
    for (PSStreamTuple *tuple in _stream) {
        PSStreamTuple * result = [self.actionChain action:tuple];
        continueIf(!result);
        [new_stream addObject:result];
        
        BOOL stop = NO;
        doIf(action, action(result, &stop));
        breakIf(stop);
    }
    _stream = new_stream;
    _actionChain = nil;
}

#pragma mark - NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id  _Nonnull *)buffer count:(NSUInteger)len{
    state->mutationsPtr = (unsigned long *)&state->mutationsPtr;
    
    NSUInteger itemCount = [self _itemCount];
    NSInteger count = MIN(len, itemCount - state->state);
    
    if (count > 0) {
        for (NSUInteger i = 0, p = state->state; i < count; i++, p++) {
            buffer[i] = [self _itemAtIndex:p];
        }
        state->state += count;
    }else{
        count = 0;
    }
    state->itemsPtr = buffer;
    return count;
}

- (id)_itemAtIndex:(NSUInteger)index{
    return self.stream[index].actualValue;
}

- (NSUInteger)_itemCount{
    return self.stream.count;
}

@end

@implementation PSStream (Select)
- (PSStream *)where:(BOOL (^)(id))condition{
    self.actionChain.nextAction = [PSStreamWhereAction actionWithBlock:condition];
    return self;
}

- (PSStream *)select:(id (^)(id))select{
    self.actionChain.nextAction = [PSStreamSelectAction actionWithBlock:select];
    return self;
}

- (PSStream *)ofType:(Class)type{
    return [self where:^BOOL(id e) {
        return [e isKindOfClass:type];
    }];
}
@end
@implementation PSStream (Range)
- (PSStream *)skip:(NSUInteger)skip{
    __block NSUInteger count = 0;
    return [self where:^BOOL(id e) {
        return count ++ >= skip;
    }];
}

- (PSStream *)skipWhile:(BOOL (^)(id))skip{
    __block BOOL isSkip = YES;
    return [self where:^BOOL(id e) {
        returnValIf(!isSkip, YES);
        return isSkip = skip(e);
    }];
}

- (PSStream *)take:(NSUInteger)take{
    __block NSUInteger count = 0;
    return [self where:^BOOL(id e) {
        return count ++ < take;
    }];
}

- (PSStream *)takeWhile:(BOOL (^)(id))take{
    __block BOOL isTake = YES;
    return [self where:^BOOL(id e) {
        returnValIf(!isTake, NO);
        return isTake = take(e);
    }];
}

- (PSStream *)rangeOfSkip:(NSUInteger)skip take:(NSUInteger)take{
    return [[self skip:skip] take:take];
}

- (NSUInteger)count{
    [self doAction:nil];
    return _stream.count;
}
@end
@implementation PSStream (Operation)
- (id)first{
    [self doAction:nil];
    return [_stream firstObject].actualValue;
}

- (id)last{
    [self doAction:nil];
    return [_stream lastObject].actualValue;
}

//这里应该用算法减少比较次数，但暂时没时间
- (id)max:(NSComparator)cmptr{
    __block id result = nil;
    [self doAction:^(PSStreamTuple *tuple, BOOL *stop) {
        if (result == nil) {
            result = [tuple actualValue];
        }else if (cmptr(result, [tuple actualValue]) == NSOrderedDescending) {
            result = [tuple actualValue];
        }
    }];
    return result;
}
//这里应该用算法减少比较次数，但暂时没时间
- (id)min:(NSComparator)cmptr{
    __block id result = nil;
    [self doAction:^(PSStreamTuple *tuple, BOOL *stop) {
        if (result == nil) {
            result = [tuple actualValue];
        }else if (cmptr(result, [tuple actualValue]) == NSOrderedAscending) {
            result = [tuple actualValue];
        }
    }];
    return result;
}

- (BOOL)contains:(id)obj{
    [self doAction:nil];
    return [_stream containsObject:obj];
}

- (id)elementAt:(NSUInteger)idx{
    [self doAction:nil];
    return [_stream objectAtIndex:idx];
}

- (PSStream *)orderBy:(NSComparator)cmptr{
    [self doAction:nil];
    _stream = [_stream sortedArrayUsingComparator:cmptr];
    return self;
}

- (void)foreach:(void (^)(id, NSUInteger, BOOL *))foreach{
    __block NSUInteger idx = 0;
    [self doAction:^(PSStreamTuple *result, BOOL *stop) {
        foreach([result actualValue], idx++, stop);
    }];
}

- (PSStream *)distinct{
    NSMutableOrderedSet *set = [NSMutableOrderedSet orderedSet];
    [self doAction:^(PSStreamTuple *tuple, BOOL *stop) {
        [set addObject:[tuple actualValue]];
    }];
    return set.ps_stream;
}

- (PSStream *)reverse{
    [self doAction:nil];
    NSEnumerator *reversedEnumerator = _stream.reverseObjectEnumerator;
    NSMutableArray *array = [NSMutableArray array];
    id obj;
    while ((obj = reversedEnumerator.nextObject)) {
        [array addObject:obj];
    }
    _stream = array;
    return self;
}
@end
@implementation PSStream (Statistics)

- (NSNumber *)sum{
#define CALCULATE(type) \
    if (strcmp(argType, @encode(int)) == 0) { \
        type sum = 0, value = 0; \
        [result getValue:&sum]; [e getValue:&value]; \
        result = @(sum += value); \
    }
    __block NSNumber *result = nil;
    [self foreach:^(id  _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([e isKindOfClass:NSNumber.class], @"sum can only calculate value type NSNumber.");
        if (idx == 0) {
            result = e;
        }else{
            const char *argType = [e objCType];
            CALCULATE(int)
            else CALCULATE(short)
            else CALCULATE(long)
            else CALCULATE(long long)
            else CALCULATE(unsigned int)
            else CALCULATE(unsigned short)
            else CALCULATE(unsigned long)
            else CALCULATE(unsigned long long)
            else CALCULATE(float)
            else CALCULATE(double)
            else{
                NSAssert(NO, @"can not calculate type :%s", argType);
            }
        }
    }];
    return result;
#undef CALCULATE
}

- (NSNumber *)max{
#define CALCULATE(type) \
    if (strcmp(argType, @encode(type)) == 0){ \
        type max = 0, value = 0; \
        [result getValue:&max]; [e getValue:&value]; \
        result = @(MAX(max, value));\
    }
    
    __block NSNumber *result = nil;
    [self foreach:^(id  _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([e isKindOfClass:NSNumber.class], @"max can only calculate value type NSNumber.");
        if (idx == 0) {
            result = e;
        }else{
            const char *argType = [e objCType];
            CALCULATE(int)
            else CALCULATE(short)
            else CALCULATE(long)
            else CALCULATE(long long)
            else CALCULATE(unsigned int)
            else CALCULATE(unsigned short)
            else CALCULATE(unsigned long)
            else CALCULATE(unsigned long long)
            else CALCULATE(float)
            else CALCULATE(double)
            else{
                NSAssert(NO, @"can not calculate type :%s", argType);
            }
        }
    }];
    return result;
#undef CALCULATE
}

- (NSNumber *)min{
#define CALCULATE(type) \
    if (strcmp(argType, @encode(type)) == 0) { \
        type max = 0, value = 0; \
        [result getValue:&max]; [e getValue:&value]; \
        result = @(MIN(max, value)); \
    }
    
    __block NSNumber *result = nil;
    [self foreach:^(id  _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([e isKindOfClass:NSNumber.class], @"max can only calculate value type NSNumber.");
        if (idx == 0) {
            result = e;
        }else{
            const char *argType = [e objCType];
            CALCULATE(int)
            else CALCULATE(short)
            else CALCULATE(long)
            else CALCULATE(long long)
            else CALCULATE(unsigned int)
            else CALCULATE(unsigned short)
            else CALCULATE(unsigned long)
            else CALCULATE(unsigned long long)
            else CALCULATE(float)
            else CALCULATE(double)
            else{
                NSAssert(NO, @"can not calculate type :%s", argType);
            }
        }
    }];
    return result;
#undef CALCULATE
}

- (NSNumber *)average{
    NSNumber *sum = self.sum;
#define CALCULATE(type) \
    if (strcmp(argType, @encode(type)) == 0) { \
        type result; \
        [sum getValue:&result]; \
        return @(result * 1.00f / self.count); \
    }
    
    const char *argType = [sum objCType];
    CALCULATE(int)
    else CALCULATE(short)
    else CALCULATE(long)
    else CALCULATE(long long)
    else CALCULATE(unsigned int)
    else CALCULATE(unsigned short)
    else CALCULATE(unsigned long)
    else CALCULATE(unsigned long long)
    else CALCULATE(float)
    else CALCULATE(double)
    else{
        NSAssert(NO, @"can not calculate type :%s", argType);
    }
    return nil;
#undef CALCULATE
}

@end
@implementation PSStream (Convert)

- (NSDictionary *)dictionary:(id (^)(id))dictionary{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [self doAction:^(PSStreamTuple *tuple, BOOL *stop) {
        PSStreamTuple *key_value = dictionary(tuple.actualValue);
        PSUnpack(NSString *key, id value) = key_value.actualValue;
        [dic setObject:value forKey:key];
    }];
    return dic;
}

- (NSArray *)array{
    NSMutableArray *array = [NSMutableArray array];
    [self doAction:^(PSStreamTuple * result, BOOL *stop) {
        [array addObject:result.actualValue];
    }];
    return array;
}

- (NSSet *)set{
    NSMutableSet *set = [NSMutableSet set];
    [self doAction:^(PSStreamTuple * result, BOOL *stop) {
        [set addObject:result.actualValue];
    }];
    return set;
}
@end

@implementation NSArray (PSStream)
- (PSStream *)ps_stream{
    return [[PSArrayStream alloc] initWithDatasource:[self copy]];
}
@end

@implementation NSDictionary (PSStream)
- (PSStream *)ps_stream{
    return [[PSDictionaryStream alloc] initWithDatasource:[self copy]];
}
@end

@implementation NSSet (PSStream)
- (PSStream *)ps_stream{
    return [[PSArrayStream alloc] initWithDatasource:[self copy]];
}
@end

@implementation NSOrderedSet (PSStream)
- (PSStream *)ps_stream{
    return [[PSArrayStream alloc] initWithDatasource:[self copy]];
}
@end

@implementation NSHashTable (PSStream)
- (PSStream *)ps_stream{
    return [[PSArrayStream alloc] initWithDatasource:[self copy]];
}
@end

@implementation NSMapTable (PSStream)
- (PSStream *)ps_stream{
    return [[PSDictionaryStream alloc] initWithDatasource:[self copy]];
}
@end

@implementation NSPointerArray (PSStream)
- (PSStream *)ps_stream{
    return [[PSArrayStream alloc] initWithDatasource:[self copy]];
}
@end