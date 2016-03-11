//
//  PSStreamTests.m
//  PSStreamTests
//
//  Created by PoiSon on 16/1/30.
//  Copyright © 2016年 PoiSon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PSStream/PSStream.h>
#import "Student.h"
#import "Teacher.h"


@interface StreamTests : XCTestCase
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation StreamTests

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

- (void)testWhere{
    NSArray *sunStu = [[self.data.ps_stream where:^BOOL(id  _Nonnull e) {
        return [[e name] hasSuffix:@"孙"];
    }] array];
    
    for (id stu in sunStu) {
        XCTAssert([[stu name] hasSuffix:@"孙"]);
    }
}

- (void)testSelect{
    NSArray *names = [[self.data.ps_stream select:^id _Nonnull(id  _Nonnull e) {
        return [e name];
    }] array];
    for (NSString *name in names) {
        XCTAssert([name isKindOfClass:[NSString class]]);
    }
}

- (void)testOfType{
    NSArray *teas = [[self.data.ps_stream ofType:[Teacher class]] array];
    for (id obj in teas) {
        XCTAssert([obj isKindOfClass:[Teacher class]]);
    }
}

- (void)testGroupBy{
    NSArray *groups = [self.data.ps_stream groupBy:^id _Nonnull(id  _Nonnull e) {
        return [[e name] substringWithRange:NSMakeRange(0, 1)];
    }].array;
    
    XCTAssert(groups.count == 4);
}

- (void)testRange{
    NSArray *skips = [[self.data.ps_stream skip:3] array];
    XCTAssert([[skips[0] name] isEqualToString:[self.data[3] name]]);
    XCTAssert(skips.count == self.data.count - 3);
    
    NSArray *takes = [[self.data.ps_stream take:10] array];
    XCTAssert(takes.count == 10);
    
    NSArray *ranges = [[self.data.ps_stream rangeOfSkip:3 take:3] array];
    XCTAssert(ranges.count == 3);
}

- (void)testStatistics{
    NSArray *array = @[@5, @6, @9, @1, @3, @8, @2, @4, @7];
    
    NSNumber *sum = [array.ps_stream sum];
    XCTAssert([sum isEqualToNumber:@(45)]);
    
    NSNumber *max = [array.ps_stream max];
    XCTAssert([max isEqualToNumber:@(9)]);
    
    NSNumber *min = [array.ps_stream min];
    XCTAssert([min isEqualToNumber:@(1)]);
    
    NSNumber *averages = [array.ps_stream average];
    XCTAssert([averages isEqualToNumber:@(5)]);
}

@end
