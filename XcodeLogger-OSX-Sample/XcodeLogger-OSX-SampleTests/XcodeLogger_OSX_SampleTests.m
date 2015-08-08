//
//  XcodeLogger_OSX_SampleTests.m
//  XcodeLogger-OSX-SampleTests
//
//  Created by Razvan Alin Tanase on 15/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface XcodeLogger_OSX_SampleTests : XCTestCase

@end

@implementation XcodeLogger_OSX_SampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
