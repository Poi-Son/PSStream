//
//  PSStreamWhereAction.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamAction.h"

NS_ASSUME_NONNULL_BEGIN
@interface PSStreamWhereAction : PSStreamAction
@property (nonatomic, readonly) BOOL (^block)(id e);
@end
NS_ASSUME_NONNULL_END