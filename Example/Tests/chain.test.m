//
//  chain.m
//  PSStream
//
//  Created by PoiSon on 16/3/3.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PSStream/PSStream.h>
#import "Student.h"
#import "Teacher.h"

@interface chain : XCTestCase
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation chain

- (void)setUp {
    [super setUp];
    self.data = [NSMutableArray array];
    for (int i = 1; i < 1000; i ++) {
        if (i % 2 == 0) {
            Student *newStu = [Student new];
            newStu.name = [NSString stringWithFormat:@"张%@", @(i)];
            newStu.age = i;
            [self.data addObject:newStu];
        }
        if (i % 3 == 0) {
            Teacher *newTea = [Teacher new];
            newTea.name = [NSString stringWithFormat:@"王%@", @(i)];
            newTea.age = 15 + i;
            [self.data addObject:newTea];
        }
        
        if (i % 5 == 0) {
            Student *newStu = [Student new];
            newStu.name = [NSString stringWithFormat:@"吴%@", @(i)];
            newStu.age = i;
            [self.data addObject:newStu];
        }
        
        if (i % 7 == 0) {
            Student *newStu = [Student new];
            newStu.name = [NSString stringWithFormat:@"孙%@", @(i)];
            newStu.age = i;
            [self.data addObject:newStu];
        }
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChain {
    NSArray *array = [self.data.ps_stream.where(^(id e){
        return [e isKindOfClass:[Student class]];
    }).where(^(Student *e){
        return [e.name hasPrefix:@"孙"];
    }) array];
    
    for (Student *stu in array) {
        XCTAssert([stu.name hasPrefix:@"孙"]);
    }
}


@end
