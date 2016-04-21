//
//  PSStreamPack.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

@interface PSStreamTuple()
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) id obj;
@end

@implementation PSStreamTuple
- (id)actualValue{
    return self.obj ?: self.objects;
}

- (instancetype)init{
    return self;
}

+ (instancetype)tupleWithObjects:(NSArray *)values{
    NSAssert(values.count, @"can not pack nil values");
    PSStreamTuple *instance = [[self alloc] init];
    if (values.count == 1) {
        instance.obj = values[0];
    }else{
        instance.objects = values;
    }
    return instance;
}

+ (instancetype)tupleWithObjects:(NSArray *)objects forKeys:(NSArray *)keys{
    NSAssert(objects.count > 0, @"can not pack nil objects");
    NSAssert(objects.count == keys.count, @"pack failed cause key and object are not match.");
    PSStreamTuple *instance = [[self alloc] init];
    
    instance.obj = [NSMutableDictionary dictionary];
    [[keys.ps_stream select:^(id e){
        return [[e componentsSeparatedByString:@"="][0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }] foreach:^(id e, NSUInteger idx, BOOL *stop) {
        id value = objects[idx];
        if (value != nil) {
            [instance.obj setValue:value forKey:e];
        }
    }];
    return instance;
}

//#pragma mark - trampoline
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
//    return [self.actualValue methodSignatureForSelector:sel];
//}
//
//- (void)forwardInvocation:(NSInvocation *)invocation{
//    [invocation invokeWithTarget:self.actualValue];
//}
//
//- (BOOL)respondsToSelector:(SEL)aSelector{
//    return [self.actualValue respondsToSelector:aSelector];
//}
//
//- (id)objectAtIndexedSubscript:(NSUInteger)idx{
//    doIf(self.objects == nil, [self.obj doesNotRecognizeSelector:@selector(objectAtIndexedSubscript:)]);
//    return self.objects[idx];
//}
//
//- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key{
//    doIf(self.obj == nil, [self.objects doesNotRecognizeSelector:@selector(setObject:forKeyedSubscript:)]);
//    [self.obj setValue:obj forKey:key];
//}
//
//- (id)objectForKeyedSubscript:(NSString *)key{
//    doIf(self.obj == nil, [self.objects doesNotRecognizeSelector:@selector(objectForKeyedSubscript:)]);
//    return [self.obj valueForKey:key];
//}
@end

@implementation PSStreamUnpackTrampoline
+ (instancetype)trampoline{
    static PSStreamUnpackTrampoline *trampoline = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trampoline = [[PSStreamUnpackTrampoline alloc] init];
    });
    return trampoline;
}

- (void)setObject:(id)pack forKeyedSubscript:(NSArray<NSValue *> *)variables{
    NSParameterAssert(variables != nil);
    NSAssert([pack isKindOfClass:NSArray.class], @"Can not unpack cause it was not an array tuple.");
    [variables enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong id *ptr = (__strong id *)obj.pointerValue;
        *ptr = pack[idx];
    }];
}

@end
