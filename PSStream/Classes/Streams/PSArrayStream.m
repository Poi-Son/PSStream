//
//  PSArrayStream.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

@implementation PSArrayStream
- (instancetype)initWithDatasource:(id<NSFastEnumeration>)datasource{
    if (self = [super _init]) {
        NSMutableArray<PSStreamTuple *> *array = [NSMutableArray new];
        for (id object in datasource) {
            [array addObject:PSArrayTuple(object)];
        }
        self->_stream = array;
    }
    return self;
}
@end
