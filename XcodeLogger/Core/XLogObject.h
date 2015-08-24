//
//  XLogObject.h
//  XcodeLogger
//
/* 
 *  Created by Razvan Alin Tanase on 13/07/15. https://twitter.com/razvan_tanase
 *  Copyright (c) 2015 Codebringers Software. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 *
 */// Project's Source: https://github.com/codeFi/XcodeLogger

#import <Foundation/Foundation.h>
#import "XLogTypes.h"

@interface XLogObject : NSObject

@property (nonatomic, copy)   NSString  *headerFormat;
@property (nonatomic, copy)   NSArray   *headerArguments;

@property (nonatomic, readonly) NSString *logHeaderDescription;
@property (nonatomic, readonly) NSString *logDescription;
@property (nonatomic, readonly) NSString *buildScheme;
@property (nonatomic, readonly) NSString *outputColor;
@property (nonatomic, readonly) NSString *newlinesAfterHeader;
@property (nonatomic, readonly) NSString *newlinesAfterOutput;

- (instancetype)initWithLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                  colorsEnabled:(BOOL)paramColorsEnabled;

- (void)setBuildScheme:(NSString *)buildScheme;

- (void)setLogHeaderDescription:(NSString *)paramLogDescription;
- (void)setColorForLogHeaderDescription:(XLColor *)paramColor;

- (void)setTextColorWithRed:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue;
- (void)setTextColor:(XLColor *)paramTextColor;

- (void)setBackgroundColorWithRed:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue;
- (void)setBackgroundColor:(XLColor *)paramTextColor;

- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)numberOfNewLinesAfterHeader;
- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)numberOfNewLinesAfterOutput;

- (XLOGGER_TYPE)logType;
- (XLOGGER_LEVEL)logLevel;

+ (NSString *)stringFromLogType:(XLOGGER_TYPE)paramLogType;
+ (NSString *)stringFromLogLevel:(XLOGGER_LEVEL)paramLogLevel;

@end
