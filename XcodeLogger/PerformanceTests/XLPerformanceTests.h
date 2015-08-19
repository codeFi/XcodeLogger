//
//  XLPerformanceTests.h
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 14/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import <Foundation/Foundation.h>

// #define ENABLE_COCOALUMBERJACK

@interface XLPerformanceTests : NSObject

+ (void)startDefaultPerformanceTest;
+ (void)startPerformanceTestWithNumberOfRuns:(NSUInteger)numberOfRuns
                       numberOfIterations:(NSUInteger)numberOfIterations;
@end
