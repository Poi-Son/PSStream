//
//  PSStream.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PSStreamTuple;
NS_ASSUME_NONNULL_BEGIN
/**
 * 延迟计算与立即计算
 */
@interface PSStream : NSObject<NSFastEnumeration>{
    NSArray<PSStreamTuple *> *_stream;
}
- (instancetype)initWithDatasource:(id<NSFastEnumeration>)datasource;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
@end

/**
 *  筛选与投影
 */
@interface PSStream (Select)
- (PSStream *)where:(BOOL (^)(id e))condition;/**< 筛选指定条件的元素 */
- (PSStream *)select:(id (^)(id e))select;/**< 将集合中的每个元素投影到新的集合中 */
- (PSStream *)ofType:(Class)type;/**< 筛选指定类型的元素 */
@end

/**
 *  元素分区
 */
@interface PSStream (Range)
- (PSStream *)skip:(NSUInteger)skip;/**< 去掉前几个 */
- (PSStream *)skipWhile:(BOOL (^)(id e))skip;/**< 跳过,直到满足条件 */
- (PSStream *)take:(NSUInteger)take;/**< 取前几个 */
- (PSStream *)takeWhile:(BOOL (^)(id e))take;/**< 取元素, 直到满足条件 */
- (PSStream *)rangeOfSkip:(NSUInteger)skip take:(NSUInteger)take;/**< 取范围里的元素 */
- (NSUInteger)count;/**< 集合个数 */
@end

/**
 *  元素操作
 */
@interface PSStream (Operation)
- (id)first;/**< 第一个元素 */
- (id)last;/**< 最后一个元素 */
- (id)max:(NSComparator)cmptr;/**< 最大的元素 */
- (id)min:(NSComparator)cmptr;/**< 最小的元素 */
- (BOOL)contains:(id)obj;/**< 是否包含元素 */
- (id)elementAt:(NSUInteger)idx;/**< 取第idx个元素 */
- (PSStream *)orderBy:(NSComparator)cmptr;/**< 排序 */
- (void)foreach:(void (^)(id e, NSUInteger idx, BOOL *stop))foreach;/**< 遍历元素 */
- (PSStream *)distinct;/**< 去除重复项 */
- (PSStream *)reverse;/**< 反序 */
@end

/**
 *  统计, 针对元素是NSNumber的元素
 */
@interface PSStream (Statistics)
- (NSNumber *)sum;
- (NSNumber *)max;
- (NSNumber *)min;
- (NSNumber *)average;
@end

/**
 *  将流转化为NSDictionary、NSArray、NSSet
 */
@interface PSStream (Convert)
- (NSDictionary *)dictionary:(id(^)(id e))dictionary;/**< return PSArray(key, value); */
- (NSArray *)array;
- (NSSet *)set;
@end


#pragma mark - 将来再扩展
@interface NSArray (PSStream)
@property (nonatomic, readonly) PSStream *ps_stream;
@end

@interface NSDictionary (PSStream)
/** NSDictionary转换成PSStream之后进行枚举时, key = e[0], vlaue = [1]. */
@property (nonatomic, readonly) PSStream *ps_stream;
@end

@interface NSSet (PSStream)
@property (nonatomic, readonly) PSStream *ps_stream;
@end

@interface NSOrderedSet (PSStream)
@property (nonatomic, readonly) PSStream *ps_stream;
@end

@interface NSHashTable (PSStream)
@property (nonatomic, readonly) PSStream *ps_stream;
@end

@interface NSMapTable (PSStream)
@property (nonatomic, readonly) PSStream *ps_stream;
@end

@interface NSPointerArray (PSStream)
@property (nonatomic, readonly) PSStream *ps_stream;
@end
NS_ASSUME_NONNULL_END