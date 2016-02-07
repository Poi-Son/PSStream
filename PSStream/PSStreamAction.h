//
//  PSStreamAction.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface PSStreamAction : NSObject
@property (nonatomic, strong) PSStreamAction *nextAction;
@property (nonatomic, readonly) PSStreamAction *lastAction;
@property (nonatomic, readonly) id block;

+ (instancetype)actionWithBlock:(id)block;
- (instancetype)initWithBlock:(id)block;

- (nullable id)action:(id)value;

@end
NS_ASSUME_NONNULL_END