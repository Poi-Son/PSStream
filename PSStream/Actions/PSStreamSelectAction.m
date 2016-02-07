//
//  PSStreamSelectAction.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

@implementation PSStreamSelectAction
@dynamic block;

- (id)action:(PSStreamTuple *)value{
    id result = self.block(value.actualValue);
    returnValIf(!result, nil);
    result = object_getClass(result) == PSStreamTuple.class ? result : PSArrayTuple(result);
    return [self.nextAction action:result];
}
@end
