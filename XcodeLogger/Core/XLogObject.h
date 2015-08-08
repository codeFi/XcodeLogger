//
//  XLogObject.h
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 13/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLogTypes.h"

@interface XLogObject : NSObject

@property (nonatomic, copy)   NSString  *headerFormat;
@property (nonatomic, copy)   NSArray   *headerArguments;

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *buildScheme;
@property (nonatomic, readonly) NSString *outputColor;
@property (nonatomic, readonly) NSString *newlinesAfterHeader;
@property (nonatomic, readonly) NSString *newlinesAfterOutput;


- (instancetype)initWithLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel;

- (void)setBuildScheme:(NSString *)buildScheme;

- (void)setTextColorWithRed:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue;
- (void)setBackgroundColorWithRed:(NSUInteger)red Green:(NSUInteger)green Blue:(NSUInteger)blue;

- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)numberOfNewLinesAfterHeader;
- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)numberOfNewLinesAfterOutput;


@end
