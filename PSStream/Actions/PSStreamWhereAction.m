//
//  PSStreamWhereAction.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

@implementation PSStreamWhereAction
@dynamic block;

- (id)action:(PSStreamTuple *)value{
    return self.block(value.actualValue) ? [self.nextAction action:value] : nil;
}
@end
