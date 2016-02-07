//
//  PSStreamAction.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

@implementation PSStreamAction
+ (instancetype)actionWithBlock:(id)block{
    return [[self alloc] initWithBlock:block];
}

- (instancetype)initWithBlock:(id)block{
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (id)action:(PSStreamTuple *)value{
    return self.nextAction ? [self.nextAction action:value] : value;
}

- (void)setNextAction:(PSStreamAction *)nextAction{
    if (_nextAction != nil) {
        _nextAction.nextAction = nextAction;
    }else{
        _nextAction = nextAction;
    }
}

- (PSStreamAction *)lastAction{
    if (_nextAction == nil) {
        return self;
    }else{
        return _nextAction.lastAction;
    }
}
@end
