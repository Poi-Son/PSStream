//
//  PSStreamPack.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PSStream/metamacros.h>

#define PSUnpack(...) \
    metamacro_foreach(PSUnpack_decl,, __VA_ARGS__) \
    int _ps_pack_state = 0; \
  _ps_unpack_after:; \
    metamacro_foreach(PSUnpack_decl_assign,, __VA_ARGS__) \
    if (_ps_pack_state != 0) _ps_pack_state = 2; \
    while(_ps_pack_state != 2) \
        if (_ps_pack_state == 1) \
            goto _ps_unpack_after; \
        else \
            for(; _ps_pack_state != 1; _ps_pack_state = 1) \
                [PSStreamUnpackTrampoline trampoline][@[ metamacro_foreach(PSUnpack_value,, __VA_ARGS__)]]

#define PSUnpack_decl_name(INDEX) metamacro_concat(metamacro_concat(_var, __LINE__), INDEX)
#define PSUnpack_decl(INDEX, ARG) __strong id PSUnpack_decl_name(INDEX);
#define PSUnpack_decl_assign(INDEX, ARG) __strong ARG = PSUnpack_decl_name(INDEX);
#define PSUnpack_value(INDEX, ARG) [NSValue valueWithPointer:&PSUnpack_decl_name(INDEX)],


#define PSArrayTuple(...) ([PSStreamTuple tupleWithObjects:@[metamacro_foreach(_ps_object_or_nil,, __VA_ARGS__)]])
#define _ps_object_or_nil(index, arg) (arg) ?: [NSNull null],

#define PSObjectTuple(...) \
    ({ \
        metamacro_foreach(PSObject_decl_assign,, __VA_ARGS__) \
        metamacro_foreach(PSObject_decl,, __VA_ARGS__) \
        [PSStreamTuple tupleWithObjects:@[ metamacro_foreach(PSObject_value,, __VA_ARGS__) ] forKeys:@[ metamacro_foreach(PSObject_key,, __VA_ARGS__) ]]; \
    })

#define PSObject_decl_assign(INDEX, ARG) __strong id ARG;
#define PSObject_decl(INDEX, ARG) __strong id PSUnpack_decl_name(INDEX) = ((ARG) ?: [NSNull null]);
#define PSObject_key(INDEX, ARG) @#ARG,
#define PSObject_value(INDEX, ARG) PSUnpack_decl_name(INDEX),

NS_ASSUME_NONNULL_BEGIN
@interface PSStreamTuple : NSObject
@property (nonatomic, readonly) id actualValue;

+ (instancetype)tupleWithObjects:(NSArray *)objects;
+ (instancetype)tupleWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

//
//- (id)objectAtIndexedSubscript:(NSUInteger)idx;
//- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
//- (nullable id)objectForKeyedSubscript:(NSString *)key;
@end

@interface PSStreamUnpackTrampoline : NSObject
+ (instancetype)trampoline;
- (void)setObject:(id)obj forKeyedSubscript:(nonnull id<NSCopying>)key;
@end
NS_ASSUME_NONNULL_END
