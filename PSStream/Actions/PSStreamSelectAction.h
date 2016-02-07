//
//  PSStreamSelectAction.h
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamAction.h"

@interface PSStreamSelectAction : PSStreamAction
@property (nonatomic, readonly) id (^block)(id e);
@end
