//
//  XLPerformanceTests.m
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 14/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import "XLPerformanceTests.h"
#import "XcodeLogger.h"

static NSString *key_XLOG = @"XLOG";
static NSString *key_XLOG_NH = @"XLOG_NH";
static NSString *key_XLOG_INFO = @"XLOG_INFO";
static NSString *key_XLOG_HIGHLIGHT = @"XLOG_HIGHLIGHT";
static NSString *key_XLOG_WARNING = @"XLOG_WARNING";
static NSString *key_XLOG_ERROR = @"XLOG_ERROR";
static NSString *key_NSLOG = @"NSLOG";

@implementation XLPerformanceTests

#pragma mark - TESTS
+ (void)startDefaultPerformanceTest {
    
    XLog_INFO(@"\n\nSTARTING DEFAULT TEST...\n\n");
    XLog_NH(@"This test consists of a single-pass, 1.000 loop iterations for each XLog Level including NSLog.\nThe final results will be shown when finished.");
    
    XLog_NH(@"TEST IS STARTING IN 5 SECONDS...");
    
    sleep(5);
    
    NSDictionary *results = [self startTestWithNumberOfIterations:1000];
    
    XLog_INFO(@"TESTS FINISHED.\nTHE TESTS RESULTS ARE:\n");
    
    XLog_NH(@"XLOG:SIMPLE    > %f seconds",[(NSNumber *)results[key_XLOG] doubleValue]);
    XLog_NH(@"XLOG:SIMPLE_NH > %f seconds",[(NSNumber *)results[key_XLOG_NH] doubleValue]);
    XLog_NH(@"XLOG:INFO      > %f seconds",[(NSNumber *)results[key_XLOG_INFO] doubleValue]);
    XLog_NH(@"XLOG:HIGHLIGHT > %f seconds",[(NSNumber *)results[key_XLOG_HIGHLIGHT] doubleValue]);
    XLog_NH(@"XLOG:WARNING   > %f seconds",[(NSNumber *)results[key_XLOG_WARNING] doubleValue]);
    XLog_NH(@"XLOG:ERROR     > %f seconds",[(NSNumber *)results[key_XLOG_ERROR] doubleValue]);
    XLog_NH(@"NSLOG          > %f seconds",[(NSNumber *)results[key_NSLOG] doubleValue]);
    
}

+ (void)startPerformanceTestWithNumberOfRuns:(NSUInteger)numberOfRuns
                          numberOfIterations:(NSUInteger)numberOfIterations
{
    //to make an average a minimum number of 2 runs is required
    if (numberOfRuns < 2) {
        numberOfRuns = 2;
    }
    
    XLog_INFO(@"\n\nSTARTING PERFORMANCE TEST...\n\n");
    
    XLog_NH(@"This test consists of user defined multiple-pass, loop iterations for each XLog Level including NSLog.\nThe final results and their averages will be shown when finished.");
    
    XLog_NH(@"Number of Runs: %tu\nNumber of Iterations per Run: %tu",numberOfRuns,numberOfIterations);
    
    XLog_NH(@"TEST IS STARTING IN 10 SECONDS...");
    
    sleep(10);
    
    NSMutableDictionary *testsDictionary = [NSMutableDictionary dictionary];
    NSString *key_TestNumber = @"TEST_";
    
    for (NSUInteger testsCount = 1; testsCount <= numberOfRuns; testsCount++) {
        XLog_HIGHLIGHT(@"\n\nRUNNING TEST NUMBER %tu\n\n", testsCount);
        NSDictionary *currentTest = [self startTestWithNumberOfIterations:numberOfIterations];
        NSString *testKey = [key_TestNumber stringByAppendingString:[NSString stringWithFormat:@"%tu",testsCount]];
        [testsDictionary setObject:currentTest forKey:testKey];
    }
    
    XLog_INFO(@"\n\nTESTS FINISHED (%tu RUNS / %tu ITERATIONS). PREPARING RESULTS...\n\n",numberOfRuns,numberOfIterations);
    
   static double sum_XLOG;
   static double sum_XLOG_NH;
   static double sum_XLOG_INFO;
   static double sum_XLOG_HIGHLIGHT;
   static double sum_XLOG_WARNING;
   static double sum_XLOG_ERROR;
   static double sum_NSLOG;
    
    NSString *result_XLOG = [NSString string];
    NSString *result_XLOG_NH = [NSString string];
    NSString *result_XLOG_INFO = [NSString string];
    NSString *result_XLOG_HIGHLIGHT = [NSString string];
    NSString *result_XLOG_WARNING = [NSString string];
    NSString *result_XLOG_ERROR = [NSString string];
    NSString *result_NSLOG = [NSString string];
    
    NSArray *keys = [testsDictionary allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString *dictionaryKey in sortedKeys) {
        NSDictionary *currentDictionary = testsDictionary[dictionaryKey];
        
        result_XLOG = [result_XLOG stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_NH = [result_XLOG_NH stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_INFO = [result_XLOG_INFO stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_HIGHLIGHT = [result_XLOG_HIGHLIGHT stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_WARNING = [result_XLOG_WARNING stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_ERROR = [result_XLOG_ERROR stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_NSLOG = [result_NSLOG stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        
        for (NSString *resultKey in currentDictionary) {
            
            sum_XLOG += [self valueByComparingKey:key_XLOG
                                      withDictKey:resultKey
                                         fromDict:currentDictionary];
            
            result_XLOG = [self stringByComparingKey:key_XLOG
                                         withDictKey:resultKey
                                            fromDict:currentDictionary
                                    appendWithString:result_XLOG];
            
            sum_XLOG_NH += [self valueByComparingKey:key_XLOG_NH
                                         withDictKey:resultKey
                                            fromDict:currentDictionary];
            
            result_XLOG_NH = [self stringByComparingKey:key_XLOG_NH
                                            withDictKey:resultKey
                                               fromDict:currentDictionary
                                       appendWithString:result_XLOG_NH];
            
            sum_XLOG_INFO += [self valueByComparingKey:key_XLOG_INFO
                                           withDictKey:resultKey
                                              fromDict:currentDictionary];
            
            result_XLOG_INFO = [self stringByComparingKey:key_XLOG_INFO
                                              withDictKey:resultKey
                                                 fromDict:currentDictionary
                                         appendWithString:result_XLOG_INFO];
            
            sum_XLOG_HIGHLIGHT += [self valueByComparingKey:key_XLOG_HIGHLIGHT
                                                withDictKey:resultKey
                                                   fromDict:currentDictionary];
            
            result_XLOG_HIGHLIGHT = [self stringByComparingKey:key_XLOG_HIGHLIGHT
                                                   withDictKey:resultKey
                                                      fromDict:currentDictionary
                                              appendWithString:result_XLOG_HIGHLIGHT];
            
            sum_XLOG_WARNING += [self valueByComparingKey:key_XLOG_WARNING
                                              withDictKey:resultKey
                                                 fromDict:currentDictionary];
            
            result_XLOG_WARNING = [self stringByComparingKey:key_XLOG_WARNING
                                                 withDictKey:resultKey
                                                    fromDict:currentDictionary
                                            appendWithString:result_XLOG_WARNING];
            
            sum_XLOG_ERROR += [self valueByComparingKey:key_XLOG_ERROR
                                            withDictKey:resultKey
                                               fromDict:currentDictionary];
            
            result_XLOG_ERROR = [self stringByComparingKey:key_XLOG_ERROR
                                               withDictKey:resultKey
                                                  fromDict:currentDictionary
                                          appendWithString:result_XLOG_ERROR];
            
            sum_NSLOG += [self valueByComparingKey:key_NSLOG
                                       withDictKey:resultKey
                                          fromDict:currentDictionary];
            
            result_NSLOG = [self stringByComparingKey:key_NSLOG
                                          withDictKey:resultKey
                                             fromDict:currentDictionary
                                     appendWithString:result_NSLOG];
            
            
        }
    }
    
    
    result_NSLOG          = [self replaceLastCharacters:@", " fromString:result_NSLOG withString:@"."];
    result_XLOG           = [self replaceLastCharacters:@", " fromString:result_XLOG withString:@"."];
    result_XLOG_NH        = [self replaceLastCharacters:@", " fromString:result_XLOG_NH withString:@"."];
    result_XLOG_INFO      = [self replaceLastCharacters:@", " fromString:result_XLOG_INFO withString:@"."];
    result_XLOG_HIGHLIGHT = [self replaceLastCharacters:@", " fromString:result_XLOG_HIGHLIGHT withString:@"."];
    result_XLOG_WARNING   = [self replaceLastCharacters:@", " fromString:result_XLOG_WARNING withString:@"."];
    result_XLOG_ERROR     = [self replaceLastCharacters:@", " fromString:result_XLOG_ERROR withString:@"."];
    
    XLog_HIGHLIGHT(@"\n\nDONE!\n\n");
    
    XLog_NH(@"NSLOG          > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_NSLOG, sum_NSLOG/numberOfRuns, result_NSLOG);
    XLog_NH(@"XLOG           > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG, sum_XLOG/numberOfRuns, result_XLOG);
    XLog_NH(@"XLOG_NH        > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_NH, sum_XLOG_NH/numberOfRuns, result_XLOG_NH);
    XLog_NH(@"XLOG_INFO      > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_INFO, sum_XLOG_INFO/numberOfRuns, result_XLOG_INFO);
    XLog_NH(@"XLOG_HIGHLIGHT > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_HIGHLIGHT, sum_XLOG_HIGHLIGHT/numberOfRuns, result_XLOG_HIGHLIGHT);
    XLog_NH(@"XLOG_WARNING   > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_WARNING, sum_XLOG_WARNING/numberOfRuns, result_XLOG_WARNING);
    XLog_NH(@"XLOG_ERROR     > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_ERROR, sum_XLOG_ERROR/numberOfRuns, result_XLOG_ERROR);
    
    
}

+ (NSDictionary *)startTestWithNumberOfIterations:(NSUInteger)numberOfIterations
{
    
    static double secondsPassed = 0;
    
   static NSDate *startTime;
    
   static NSNumber *result_XLOG;
   static NSNumber *result_XLOG_NH;
   static NSNumber *result_XLOG_INFO;
   static NSNumber *result_XLOG_HIGHLIGHT;
   static NSNumber *result_XLOG_WARNING;
   static NSNumber *result_XLOG_ERROR;
   static NSNumber *result_NSLOG;
    
    XLog_HIGHLIGHT(@"\nTesting XLog Level: Simple...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog(@"XLOG:SIMPLE > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_XLOG = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_HIGHLIGHT(@"\nTesting XLog Level: Simple, No Header...\n");
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_NH(@"XLOG:SIMPLE_NH > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_XLOG_NH = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_HIGHLIGHT(@"\nTesting XLog Level: Info...\n");
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_INFO(@"XLOG:INFO > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_XLOG_INFO = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_HIGHLIGHT(@"\nTesting XLog Level: Highlight...\n");
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_HIGHLIGHT(@"XLOG:HIGHLIGHT > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_XLOG_HIGHLIGHT = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_HIGHLIGHT(@"\nTesting XLog Level: Warning...\n");
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_WARNING(@"XLOG:WARNING > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_XLOG_WARNING = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_HIGHLIGHT(@"\nTesting XLog Level: Error...\n");
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_ERROR(@"XLOG:ERROR > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_XLOG_ERROR = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_HIGHLIGHT(@"\nTesting NSLog...\n");
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        NSLog(@"NSLOG > Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    result_NSLOG = [NSNumber numberWithDouble:secondsPassed];
    
    
    return @{key_XLOG:result_XLOG,
             key_XLOG_NH:result_XLOG_NH,
             key_XLOG_INFO:result_XLOG_INFO,
             key_XLOG_HIGHLIGHT:result_XLOG_HIGHLIGHT,
             key_XLOG_WARNING:result_XLOG_WARNING,
             key_XLOG_ERROR:result_XLOG_ERROR,
             key_NSLOG:result_NSLOG};
}


#pragma mark - HELPERS
+ (double)valueByComparingKey:(NSString *)originalKey
                  withDictKey:(NSString *)dictKey
                     fromDict:(NSDictionary *)dict
{
    double value = 0;
    if ([originalKey isEqualToString:dictKey]) {
        value = [(NSNumber *)dict[dictKey] doubleValue];
    }
    return value;
}

+ (NSString *)stringByComparingKey:(NSString *)originalKey
                       withDictKey:(NSString *)dictKey
                          fromDict:(NSDictionary *)dict
                  appendWithString:(NSString *)stringToAppend
{
    NSString *string = nil;
    NSString *finalString = stringToAppend;
    
    if ([originalKey isEqualToString:dictKey]) {
        string = [NSString stringWithFormat:@"%fs, ",[(NSNumber *)dict[dictKey]doubleValue]];
        finalString = [finalString stringByAppendingString:string];
    }
    return finalString;
}

+ (NSString *)removeLastNumberOfCharacters:(NSUInteger)numberOfChars fromString:(NSString *)string
{
    NSString *currentString = string;
    currentString = [currentString substringToIndex:[currentString length] - numberOfChars];
    return currentString;
}

+ (NSString *)replaceLastCharacters:(NSString *)characterString
                         fromString:(NSString *)string
                         withString:(NSString *)replacementString
{
    NSString *currentString = string;
    NSRange range = [currentString rangeOfString:characterString options:NSBackwardsSearch];
    
    if(range.location != NSNotFound) {
        currentString = [currentString stringByReplacingCharactersInRange:range
                                                               withString:replacementString];
    }
    
    return currentString;
}

@end
