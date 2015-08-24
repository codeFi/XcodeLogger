//
//  XLPerformanceTests.m
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 14/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import "XLPerformanceTests.h"
#import "XcodeLogger.h"

#ifdef ENABLE_COCOALUMBERJACK
#import <CocoaLumberjack/CocoaLumberjack.h>
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#endif

static NSString *key_XLOG           = @"XLOG";
static NSString *key_XLOG_NH        = @"XLOG_NH";
static NSString *key_XLOG_INFO      = @"XLOG_INFO";
static NSString *key_XLOG_IMPORTANT = @"XLOG_IMPORTANT";
static NSString *key_XLOG_WARNING   = @"XLOG_WARNING";
static NSString *key_XLOG_ERROR     = @"XLOG_ERROR";
static NSString *key_NSLOG          = @"NSLOG";
static NSString *key_CLJ            = @"CocoaLumberjack";

static NSMutableDictionary *testsDictionary;
static NSString *const key_TestNumber = @"TEST_";

static double sum_XLOG;
static double sum_XLOG_NH;
static double sum_XLOG_INFO;
static double sum_XLOG_IMPORTANT;
static double sum_XLOG_WARNING;
static double sum_XLOG_ERROR;
static double sum_NSLOG;
static double sum_CLJ;


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
    XLog_NH(@"XLOG:IMPORTANT > %f seconds",[(NSNumber *)results[key_XLOG_IMPORTANT] doubleValue]);
    XLog_NH(@"XLOG:WARNING   > %f seconds",[(NSNumber *)results[key_XLOG_WARNING] doubleValue]);
    XLog_NH(@"XLOG:ERROR     > %f seconds",[(NSNumber *)results[key_XLOG_ERROR] doubleValue]);
    XLog_NH(@"NSLOG          > %f seconds",[(NSNumber *)results[key_NSLOG] doubleValue]);
    
}

+ (void)startPerformanceTestWithNumberOfRuns:(NSUInteger)numberOfRuns
                          numberOfIterations:(NSUInteger)numberOfIterations
{

#ifdef ENABLE_COCOALUMBERJACK
    //[DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    //[[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    //[[DDTTYLogger sharedInstance] setForegroundColor:[NSColor greenColor] backgroundColor:[NSColor blackColor] forFlag:DDLogFlagVerbose];
#endif
    
    //to make an average a minimum number of 2 runs is required
    if (numberOfRuns < 2) {
        numberOfRuns = 2;
    }
    
    XLog_INFO(@"\n\nSTARTING PERFORMANCE TEST...\n\n");
    
    XLog_NH(@"This test consists of multiple runs composed of loop sets for each XLog Level, NSLog and (optional) CocoaLumberjack.\nThere's a 2 seconds break between each set.\nThe final results and their averages will be printed when the entire test finishes.");
    
    XLog_NH(@"Number of Runs: %tu\nNumber of Iterations per Run, per Log: %tu",numberOfRuns,numberOfIterations);
    
    XLog_NH(@"TEST STARTS IN 3 SECONDS...");
    
    sleep(3);
    
    if (!testsDictionary)testsDictionary = [NSMutableDictionary dictionary];
    
    
    for (NSUInteger testsCount = 1; testsCount <= numberOfRuns; testsCount++) {
        XLog_IMPORTANT(@"\n\nRUNNING TEST NUMBER %tu\n\n", testsCount);
        sleep(2);
        NSDictionary *currentTest = [self startTestWithNumberOfIterations:numberOfIterations];
        NSString *testKey = [key_TestNumber stringByAppendingString:[NSString stringWithFormat:@"%tu",testsCount]];
        [testsDictionary setObject:currentTest forKey:testKey];
    }
    
    XLog_INFO(@"\n\nTESTS FINISHED (%tu RUNS / %tu ITERATIONS). PREPARING RESULTS...\n\n",numberOfRuns,numberOfIterations);
    
    
    
    NSString *result_XLOG = [NSString string];
    NSString *result_XLOG_NH = [NSString string];
    NSString *result_XLOG_INFO = [NSString string];
    NSString *result_XLOG_IMPORTANT = [NSString string];
    NSString *result_XLOG_WARNING = [NSString string];
    NSString *result_XLOG_ERROR = [NSString string];
    NSString *result_NSLOG = [NSString string];
    NSString *result_CLJ = [NSString string];
    
    NSArray *keys = [testsDictionary allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
    for (NSString *dictionaryKey in sortedKeys) {
        NSDictionary *currentDictionary = testsDictionary[dictionaryKey];
        
        result_XLOG = [result_XLOG stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_NH = [result_XLOG_NH stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_INFO = [result_XLOG_INFO stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_IMPORTANT = [result_XLOG_IMPORTANT stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_WARNING = [result_XLOG_WARNING stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_XLOG_ERROR = [result_XLOG_ERROR stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_NSLOG = [result_NSLOG stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        result_CLJ = [result_CLJ stringByAppendingString:[NSString stringWithFormat:@"%@: ", dictionaryKey]];
        
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
            
            sum_XLOG_IMPORTANT += [self valueByComparingKey:key_XLOG_IMPORTANT
                                                withDictKey:resultKey
                                                   fromDict:currentDictionary];
            
            result_XLOG_IMPORTANT = [self stringByComparingKey:key_XLOG_IMPORTANT
                                                   withDictKey:resultKey
                                                      fromDict:currentDictionary
                                              appendWithString:result_XLOG_IMPORTANT];
            
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
            
            sum_CLJ += [self valueByComparingKey:key_CLJ
                                     withDictKey:resultKey
                                        fromDict:currentDictionary];
            
            result_CLJ = [self stringByComparingKey:key_CLJ
                                        withDictKey:resultKey
                                           fromDict:currentDictionary
                                   appendWithString:result_CLJ];
            
            
            
        }
    }
    
    
    result_NSLOG          = [self replaceLastCharacters:@", " fromString:result_NSLOG withString:@"."];
    result_CLJ            = [self replaceLastCharacters:@", " fromString:result_CLJ withString:@"."];
    result_XLOG           = [self replaceLastCharacters:@", " fromString:result_XLOG withString:@"."];
    result_XLOG_NH        = [self replaceLastCharacters:@", " fromString:result_XLOG_NH withString:@"."];
    result_XLOG_INFO      = [self replaceLastCharacters:@", " fromString:result_XLOG_INFO withString:@"."];
    result_XLOG_IMPORTANT = [self replaceLastCharacters:@", " fromString:result_XLOG_IMPORTANT withString:@"."];
    result_XLOG_WARNING   = [self replaceLastCharacters:@", " fromString:result_XLOG_WARNING withString:@"."];
    result_XLOG_ERROR     = [self replaceLastCharacters:@", " fromString:result_XLOG_ERROR withString:@"."];
    
    XLog_IMPORTANT(@"\n\nDONE!\n\n");
    
    XLog_NH(@"NSLOG          > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_NSLOG, sum_NSLOG/numberOfRuns, result_NSLOG);
    XLog_NH(@"CocoaLumberjack> TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_CLJ, sum_CLJ/numberOfRuns, result_CLJ);
    XLog_NH(@"XLOG           > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG, sum_XLOG/numberOfRuns, result_XLOG);
    XLog_NH(@"XLOG_NH        > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_NH, sum_XLOG_NH/numberOfRuns, result_XLOG_NH);
    XLog_NH(@"XLOG_INFO      > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_INFO, sum_XLOG_INFO/numberOfRuns, result_XLOG_INFO);
    XLog_NH(@"XLOG_IMPORTANT > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_IMPORTANT, sum_XLOG_IMPORTANT/numberOfRuns, result_XLOG_IMPORTANT);
    XLog_NH(@"XLOG_WARNING   > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_WARNING, sum_XLOG_WARNING/numberOfRuns, result_XLOG_WARNING);
    XLog_NH(@"XLOG_ERROR     > TOTAL TIME: %fs | AVERAGE: %fs | %@", sum_XLOG_ERROR, sum_XLOG_ERROR/numberOfRuns, result_XLOG_ERROR);
    
    
}

+ (NSDictionary *)startTestWithNumberOfIterations:(NSUInteger)numberOfIterations
{
    
    static double secondsPassed = 0;
    
    static NSDate *startTime;
    
    static NSNumber *r_XLOG;
    static NSNumber *r_XLOG_NH;
    static NSNumber *r_XLOG_INFO;
    static NSNumber *r_XLOG_IMPORTANT;
    static NSNumber *r_XLOG_WARNING;
    static NSNumber *r_XLOG_ERROR;
    static NSNumber *r_NSLOG;
#ifdef ENABLE_COCOALUMBERJACK
    static NSNumber *r_CLJ;
#endif
    
    
    XLog_IMPORTANT(@"\nTesting XLog Level: Simple...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_XLOG = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_IMPORTANT(@"\nTesting XLog Level: Simple, No Header...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_NH(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_XLOG_NH = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_IMPORTANT(@"\nTesting XLog Level: Info...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_INFO(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_XLOG_INFO = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_IMPORTANT(@"\nTesting XLog Level: IMPORTANT...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_IMPORTANT(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_XLOG_IMPORTANT = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_IMPORTANT(@"\nTesting XLog Level: Warning...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_WARNING(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_XLOG_WARNING = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_IMPORTANT(@"\nTesting XLog Level: Error...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        XLog_ERROR(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_XLOG_ERROR = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
    
    XLog_IMPORTANT(@"\nTesting NSLog...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        NSLog(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_NSLOG = [NSNumber numberWithDouble:secondsPassed];
    
    //----//
#ifdef ENABLE_COCOALUMBERJACK
    XLog_IMPORTANT(@"\nTesting CocoaLumberjack...\n");
    
    sleep(2);
    
    startTime = [NSDate date];
    for (int index = 0; index <= numberOfIterations; index++) {
        DDLogVerbose(@"Loop index: %d", index);
    }
    secondsPassed = -[startTime timeIntervalSinceNow];
    r_CLJ = [NSNumber numberWithDouble:secondsPassed];
#endif
    
    NSDictionary *resultsDictionary =  @{key_XLOG:r_XLOG,
                                         key_XLOG_NH:r_XLOG_NH,
                                         key_XLOG_INFO:r_XLOG_INFO,
                                         key_XLOG_IMPORTANT:r_XLOG_IMPORTANT,
                                         key_XLOG_WARNING:r_XLOG_WARNING,
                                         key_XLOG_ERROR:r_XLOG_ERROR,
                                         key_NSLOG:r_NSLOG,
#ifdef ENABLE_COCOALUMBERJACK
                                         key_CLJ:r_CLJ
#endif
                                         };
    
    return resultsDictionary;
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
