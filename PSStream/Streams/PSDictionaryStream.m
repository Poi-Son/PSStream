//
//  PSDictionaryStream.m
//  PSExtensions
//
//  Created by PoiSon on 15/12/30.
//  Copyright © 2015年 yerl. All rights reserved.
//

#import "PSStreamHeader_Private.h"

@implementation PSDictionaryStream

- (instancetype)initWithDatasource:(NSDictionary *)datasource{
    if (self = [super init]) {
        NSMutableArray<PSStreamTuple *> *array = [NSMutableArray new];
        for (id key in datasource) {
            [array addObject:PSArrayTuple(key, datasource[key])];
        }
        self->_stream = array;
    }
    return self;
}
@end
