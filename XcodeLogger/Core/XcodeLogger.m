//
//  XcodeLogger.m
//  XcodeLogger
//
/*
 *  Created by Razvan Alin Tanase on 02/07/15. https://twitter.com/razvan_tanase
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


#import "XcodeLogger.h"
#import "XLogObject.h"
#import "XLColorThemes.h"

static NSString *TIMESTAMP_FORMAT = @"HH:mm:ss";

static NSString *KEY_INFO_PLIST_SCHEME;

static NSString *XL_HEADER_LOG_DESCRIPTION;
static NSString *XL_HEADER_TIMESTAMP;
static NSString *XL_HEADER_CALLEE;
static NSString *XL_HEADER_FILE_NAME;
static NSString *XL_HEADER_LINE_NUMBER;
static NSString *XL_HEADER_CALLEE_METHOD;

static NSString *XLOG_OUTPUT_STRING;

static NSString *DLOG_BUILD_SCHEME_NAME;
static NSString *DVLOG_BUILD_SCHEME_NAME;

static BOOL COLORS_ENABLED  = YES;

static NSString *XL_GLOBAL_FILTER_STRING = @"GLOBAL_FILTER";
static NSMutableDictionary *XL_FILTERS_DICTIONARY;

#pragma mark - XCODE LOGGER
@interface XcodeLogger ()
@property (nonatomic, strong) NSMutableDictionary *xLogInstances;
@end

@implementation XcodeLogger

#pragma mark - PUBLIC

#pragma mark Build Schemes
- (void)setInfoPlistKeyNameForRunningSchemes:(NSString *)paramRunningSchemeKey {
    KEY_INFO_PLIST_SCHEME = paramRunningSchemeKey;
}

- (void)setBuildSchemeName:(NSString *)paramSchemeName
               forXLogType:(XLOGGER_TYPE)paramLogType
{
    switch (paramLogType) {
        case XLOGGER_TYPE_NSLOG_REPLACEMENT:
            [NSException raise:@"XcodeLogger Build Schemes Initializer"
                        format:@"Do not set a build scheme for XLog!\nThe idea is that XLog is a scheme independent logger."];
            break;
        case XLOGGER_TYPE_DEBUG_DEVELOPMENT:
            [NSException raise:@"XcodeLogger Build Schemes Initializer"
                        format:@"Do not set a build scheme for DDLog!\nIts output rules are dependent on whether there are build schemes defined for DLog and/or DVLog."];
            break;
        default:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setBuildScheme:paramSchemeName];
            }
        }
            break;
    }
    
    switch (paramLogType) {
        case XLOGGER_TYPE_DEBUG:
            DLOG_BUILD_SCHEME_NAME  = paramSchemeName.uppercaseString;
            break;
        case XLOGGER_TYPE_DEVELOPMENT:
            DVLOG_BUILD_SCHEME_NAME = paramSchemeName.uppercaseString;
            break;
        default:
            break;
    }
    
}

#pragma mark Filters
- (void)filterXLogLevels:(NSArray *)paramLogLevels
             forFileName:(NSString *)paramFileName {
    
    if (!paramLogLevels) {
        NSLog(@"<%@> XLog Levels Array can't be nil.", NSStringFromSelector(_cmd));
        return;
    }
    
    if (!XL_FILTERS_DICTIONARY) {
        XL_FILTERS_DICTIONARY = [[NSMutableDictionary alloc] init];
    }
    
    
    NSString *fileName;
    
    if (paramFileName) {
        fileName = [paramFileName uppercaseString];
    } else {
        fileName = XL_GLOBAL_FILTER_STRING;
    }
    
    NSMutableArray *logLevels = XL_FILTERS_DICTIONARY[fileName];
    
    if (!logLevels) {
        logLevels = [[NSMutableArray alloc] init];
    }
    
    for (NSNumber *logLevel in paramLogLevels) {
        if (![logLevels containsObject:logLevel]) {
            [logLevels addObject:logLevel];
        }
    }
    
    if ([logLevels count] > 0) {
        [XL_FILTERS_DICTIONARY setObject:logLevels forKey:fileName];
    }
}


#pragma mark Format
- (void)setHeaderForXLogType:(XLOGGER_TYPE)paramLogType
                       level:(XLOGGER_LEVEL)paramLogLevel
                      format:(NSString *)paramHeaderFormat
                   arguments:(NSArray *)paramArguments {
    
    if (paramLogType == XLOGGER_TYPE_ALL) {
        [NSException raise:@"Xcode Logger Set Log Header Format"
                    format:@"-[%@] operation is unavailable for XLOGGER_TYPE_ALL.\nSelect a specific Log Type instead.",NSStringFromSelector(_cmd)];
    }
    
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramLogType];
            for (XLogObject *logLevel in logLevels) {
                if ([logLevel logLevel] != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                    [logLevel setHeaderFormat:paramHeaderFormat];
                    [logLevel setHeaderArguments:paramArguments];
                }
            }
        }
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
            
            [currentLogger setHeaderFormat:paramHeaderFormat];
            [currentLogger setHeaderArguments:paramArguments];
        }
            break;
    }
}

- (void)setLogHeaderDescription:(NSString *)paramLogDescription
                     forLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel {
    
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
            [NSException raise:@"Xcode Logger Set Log Header Description"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_ALL.\nSelect a specific Log Level instead.",NSStringFromSelector(_cmd)];
            break;
        case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
            [NSException raise:@"Xcode Logger Set Log Header Description"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_SIMPLE_NO_HEADER.\nSelect another Log Level instead.",NSStringFromSelector(_cmd)];
            break;
        default:
        {
            if (paramLogType == XLOGGER_TYPE_ALL) {
                NSArray *allLoggers = [XcodeLogger getLogTypesForLogLevel:paramLogLevel];
                for (XLogObject *logObject in allLoggers) {
                    if ([logObject logLevel] != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                        [logObject setLogHeaderDescription:paramLogDescription];
                    }
                }
            } else {
                XLogObject *logObject = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
                if ([logObject logLevel] != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                    [logObject setLogHeaderDescription:paramLogDescription];
                }
            }
        }
            break;
    }
}

- (void)setLogHeaderDescription:(NSString *)paramLogDescription
                     forLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                          color:(XLColor *)paramColor {
    
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
            [NSException raise:@"Xcode Logger Set Log Header Description"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_ALL.\nSelect a specific Log Level instead.",NSStringFromSelector(_cmd)];
            break;
        case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
            [NSException raise:@"Xcode Logger Set Log Header Description"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_SIMPLE_NO_HEADER.\nSelect another Log Level instead.",NSStringFromSelector(_cmd)];
            break;
        default:
        {
            if (paramLogType == XLOGGER_TYPE_ALL) {
                NSArray *allLoggers = [XcodeLogger getLogTypesForLogLevel:paramLogLevel];
                for (XLogObject *logObject in allLoggers) {
                    if ([logObject logLevel] != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                        [logObject setLogHeaderDescription:paramLogDescription];
                        [logObject setColorForLogHeaderDescription:paramColor];
                    }
                }
            } else {
                XLogObject *logObject = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
                if ([logObject logLevel] != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                    [logObject setLogHeaderDescription:paramLogDescription];
                    [logObject setColorForLogHeaderDescription:paramColor];
                }
            }
        }
            break;
    }
}

- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramLogType
                                 level:(XLOGGER_LEVEL)paramLogLevel
{
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setNumberOfNewLinesAfterHeader:paramNumberOfLines];
            }
        }
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
            
            [currentLogger setNumberOfNewLinesAfterHeader:paramNumberOfLines];
        }
            break;
    }
}

- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramLogType
                                 level:(XLOGGER_LEVEL)paramLogLevel
{
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setNumberOfNewLinesAfterOutput:paramNumberOfLines];
            }
        }
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
            
            [currentLogger setNumberOfNewLinesAfterOutput:paramNumberOfLines];
        }
            break;
    }
}

- (void)setTimestampFormat:(NSString *)paramTimestampFormat {
    TIMESTAMP_FORMAT = paramTimestampFormat;
}

#pragma mark Colors
- (void)setColorLogsEnabled:(BOOL)paramEnableColors {
    COLORS_ENABLED = paramEnableColors;
}

- (void)setTextColorForXLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                        withRed:(NSUInteger)red
                          Green:(NSUInteger)green
                           Blue:(NSUInteger)blue
{
    
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
            [NSException raise:@"Xcode Logger Set Text Color"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_ALL.\nSelect a specific Log Level instead.",NSStringFromSelector(_cmd)];
            break;
            
        default:
        {
            if (paramLogType == XLOGGER_TYPE_ALL) {
                NSArray *allLoggers = [XcodeLogger getLogTypesForLogLevel:paramLogLevel];
                for (XLogObject *logObject in allLoggers) {
                    [logObject setTextColorWithRed:red Green:green Blue:blue];
                }
                
            } else {
                XLogObject *logObject = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
                [logObject setTextColorWithRed:red Green:green Blue:blue];
            }
        }
            break;
    }
}

- (void)setTextColor:(XLColor *)paramTextColor
         forXLogType:(XLOGGER_TYPE)paramLogType
               level:(XLOGGER_LEVEL)paramLogLevel
{
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
            [NSException raise:@"Xcode Logger Set Text Color"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_ALL.\nSelect a specific Log Level instead.",NSStringFromSelector(_cmd)];
            break;
            
        default:
        {
            if (paramLogType == XLOGGER_TYPE_ALL) {
                NSArray *allLoggers = [XcodeLogger getLogTypesForLogLevel:paramLogLevel];
                for (XLogObject *logObject in allLoggers) {
                    [logObject setTextColor:paramTextColor];
                }
                
            } else {
                XLogObject *logObject = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
                [logObject setTextColor:paramTextColor];
            }
        }
            break;
    }
}

- (void)setBackgroundColorForXLogType:(XLOGGER_TYPE)paramLogType
                                level:(XLOGGER_LEVEL)paramLogLevel
                              withRed:(NSUInteger)red
                                Green:(NSUInteger)green
                                 Blue:(NSUInteger)blue
{
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
            [NSException raise:@"Xcode Logger Set Background Color"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_ALL.\nSelect a specific Log Level instead.",NSStringFromSelector(_cmd)];
            break;
            
        default:
        {
            if (paramLogType == XLOGGER_TYPE_ALL) {
                NSArray *allLoggers = [XcodeLogger getLogTypesForLogLevel:paramLogLevel];
                for (XLogObject *logObject in allLoggers) {
                    [logObject setBackgroundColorWithRed:red Green:green Blue:blue];
                }
                
            } else {
                XLogObject *logObject = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
                [logObject setBackgroundColorWithRed:red Green:green Blue:blue];
            }
            
        }
            break;
    }
}

- (void)setBackgroundColor:(XLColor *)paramBackgroundColor
               forXLogType:(XLOGGER_TYPE)paramLogType
                     level:(XLOGGER_LEVEL)paramLogLevel
{
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_ALL:
            [NSException raise:@"Xcode Logger Set Background Color"
                        format:@"-[%@] operation is unavailable for XLOGGER_LEVEL_ALL.\nSelect a specific Log Level instead.",NSStringFromSelector(_cmd)];
            break;
            
        default:
        {
            if (paramLogType == XLOGGER_TYPE_ALL) {
                NSArray *allLoggers = [XcodeLogger getLogTypesForLogLevel:paramLogLevel];
                for (XLogObject *logObject in allLoggers) {
                    [logObject setBackgroundColor:paramBackgroundColor];
                }
                
            } else {
                XLogObject *logObject = [XcodeLogger getXLogObjectForType:paramLogType
                                                                withLevel:paramLogLevel];
                [logObject setBackgroundColor:paramBackgroundColor];
            }
        }
            break;
    }
}


#pragma mark Color Themes
- (NSArray *)availableColorThemes {
    return [[XLColorThemes sharedManager] availableColorThemes];
}

- (void)loadColorThemeWithName:(NSString *)paramColorThemeName {
    [[XLColorThemes sharedManager] loadColorThemeWithName:paramColorThemeName];
}

- (void)printAvailableColorThemes {
    XLog_NH(@"-[%@]\n\nAVAILABLE COLOR THEMES FOR XCODE LOGGER:\n%@\n\n", NSStringFromSelector(_cmd), [self availableColorThemes]);
}

- (void)printColorThemeCreationInstructions {
    XLog_NH(@"\n\n-[%@]%@\n\n",  NSStringFromSelector(_cmd), [[XLColorThemes sharedManager] themeCreationInstructions]);
}

#pragma mark - PRIVATE
#pragma mark Xcode Colors Plugin Related
+ (BOOL)checkXcodeColorsPluginIsEnabled {
    BOOL enabled;
    
    char *xcode_colors = getenv("XcodeColors");
    enabled = xcode_colors && (strcmp(xcode_colors, "YES") == 0) ? YES:NO;
    
    return enabled;
}

#pragma mark Scheme Linking
+ (BOOL)currentRunningSchemeMatches:(NSString *)paramBuildScheme
                        forXLogType:(XLOGGER_TYPE)paramLogType
{
    NSString *currentRunningScheme = [(NSString *)[[[NSBundle mainBundle] infoDictionary]
                                                   valueForKey:KEY_INFO_PLIST_SCHEME] uppercaseString];
    
    NSString *buildScheme = [paramBuildScheme uppercaseString];
    
    switch (paramLogType) {
        case XLOGGER_TYPE_DEBUG_DEVELOPMENT:
        {
            BOOL isDebug       = [currentRunningScheme isEqualToString:DLOG_BUILD_SCHEME_NAME];
            BOOL isDevelopment = [currentRunningScheme isEqualToString:DVLOG_BUILD_SCHEME_NAME];
            
            if (isDebug || isDevelopment){return YES;}
        }
            break;
            
        default:
        {
            if ([currentRunningScheme isEqualToString:buildScheme]){return YES;}
        }
            break;
    }
    return NO;
}

#pragma mark Colors
+ (NSString *)xLogFormattedStringFromString:(NSString *)paramString
                            withColorFormat:(NSString *)paramColorFormat {
    
    if (COLORS_ENABLED) {
        if (!paramColorFormat) {
            NSString *txtError = @"fg255,255,255;";
            NSString *bgdError = @"bg255,0,0;";
            
            return [NSString stringWithFormat:@"%@%@%@%@%@\n%@",
                    XCODE_COLORS_ESCAPE,
                    txtError,
                    XCODE_COLORS_ESCAPE,
                    bgdError,
                    paramString,
                    XCODE_COLORS_RESET];
        }
        
        NSString *string      = paramString;
        NSString *colorFormat = paramColorFormat;
        
        return [colorFormat stringByAppendingString:[NSString stringWithFormat:@"%@%@",string,XCODE_COLORS_RESET]];
    }
    
    return paramString;
}

#pragma mark Log Header
+ (NSString *)populateFormatString: (NSString *)formatString
                     withArguments: (NSArray *)argumentsArray
{
    if (formatString) {
        NSMutableString *finalString = [NSMutableString stringWithString:formatString];
        NSRange varRange, scanRange;
        NSUInteger length = [formatString length];
        scanRange = NSMakeRange(0, length);
        NSUInteger index = [argumentsArray count];
        while ((varRange = [formatString rangeOfString: @"%@"
                                               options: NSBackwardsSearch
                                                 range: scanRange]).length > 0 && index > 0) {
            @autoreleasepool {
                
                NSString *arg;
                
                --index;
                
                if ([argumentsArray[index] isKindOfClass:[NSNumber class]]) {
                    arg = [self getHeaderArgumentFromType:[argumentsArray[index] unsignedIntValue]];
                } else if ([argumentsArray[index] isKindOfClass:[NSString class]]) {
                    arg = argumentsArray[index];
                } else {
                    NSLog(@"UNKNOWN ARGUMENT TYPE!");
                }
                
                if (arg) {
                    [finalString replaceCharactersInRange: varRange
                                               withString: arg];
                    length = varRange.location;
                    scanRange = NSMakeRange(0, length);
                }
            }
        }
        return finalString;
    }
    return nil;
}

+ (NSString *)getHeaderArgumentFromType:(XLOGGER_ARGS)paramArgumentType
{
    switch (paramArgumentType) {
        case XLOGGER_ARGS_LOG_DESCRIPTION:
            return XL_HEADER_LOG_DESCRIPTION;
            break;
        case XLOGGER_ARGS_TIMESTAMP:
            return XL_HEADER_TIMESTAMP;
            break;
        case XLOGGER_ARGS_CALLEE:
            return XL_HEADER_CALLEE;
            break;
        case XLOGGER_ARGS_CALLEE_METHOD:
            return XL_HEADER_CALLEE_METHOD;
            break;
        case XLOGGER_ARGS_LINE_NUMBER:
            return XL_HEADER_LINE_NUMBER;
            break;
        case XLOGGER_ARGS_FILE_NAME:
            return XL_HEADER_FILE_NAME;
            break;
        default:
            break;
    }
    return nil;
}



+ (XLogObject *)getXLogObjectForType:(XLOGGER_TYPE)paramLogType
                           withLevel:(XLOGGER_LEVEL)paramLogLevel {
    
    NSString *key = [[XLogObject stringFromLogType:paramLogType]stringByAppendingString:[XLogObject stringFromLogLevel:paramLogLevel]];
    
    NSMutableDictionary *xLogInstances = [XcodeLogger sharedManager].xLogInstances;
    
    if (![xLogInstances objectForKey:key]) {
        XLogObject *logObject = [[XLogObject alloc] initWithLogType:paramLogType
                                                              level:paramLogLevel
                                                      colorsEnabled:COLORS_ENABLED];
        [xLogInstances setObject:logObject forKey:key];
        XL_HEADER_LOG_DESCRIPTION = logObject.logHeaderDescription;
        return [xLogInstances objectForKey:key];
    } else {
        XLogObject *logObject = [xLogInstances objectForKey:key];
        XL_HEADER_LOG_DESCRIPTION = logObject.logHeaderDescription;
        return logObject;
    }
    
    return nil;
}

+ (NSArray *)getLogTypesForLogLevel:(XLOGGER_LEVEL)paramLogLevel {
    
    if (paramLogLevel == XLOGGER_LEVEL_ALL) {
        NSArray *allLoggers = @[[self getLogTypesForLogLevel:XLOGGER_LEVEL_SIMPLE],
                                [self getLogTypesForLogLevel:XLOGGER_LEVEL_SIMPLE_NO_HEADER],
                                [self getLogTypesForLogLevel:XLOGGER_LEVEL_INFORMATION],
                                [self getLogTypesForLogLevel:XLOGGER_LEVEL_IMPORTANT],
                                [self getLogTypesForLogLevel:XLOGGER_LEVEL_WARNING],
                                [self getLogTypesForLogLevel:XLOGGER_LEVEL_ERROR]];
        return allLoggers;
    }
    
    
    XLogObject *XLog  = [XcodeLogger getXLogObjectForType:XLOGGER_TYPE_NSLOG_REPLACEMENT
                                                withLevel:paramLogLevel];
    XLogObject *DLog  = [XcodeLogger getXLogObjectForType:XLOGGER_TYPE_DEBUG
                                                withLevel:paramLogLevel];
    XLogObject *DVLog = [XcodeLogger getXLogObjectForType:XLOGGER_TYPE_DEVELOPMENT
                                                withLevel:paramLogLevel];
    XLogObject *DDLog = [XcodeLogger getXLogObjectForType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                                withLevel:paramLogLevel];
    XLogObject *OLog  = [XcodeLogger getXLogObjectForType:XLOGGER_TYPE_ONLINE_SERVICES
                                                withLevel:paramLogLevel];
    
    NSArray *logTypes = @[XLog, DLog, DVLog, DDLog, OLog];
    return logTypes;
}

+ (NSArray *)getLogLevelsForLogType:(XLOGGER_TYPE)paramLogType
{
    if (paramLogType == XLOGGER_TYPE_ALL) {
        NSArray *allLoggers = @[[self getLogLevelsForLogType:XLOGGER_TYPE_NSLOG_REPLACEMENT],
                                [self getLogLevelsForLogType:XLOGGER_TYPE_DEBUG],
                                [self getLogLevelsForLogType:XLOGGER_TYPE_DEVELOPMENT],
                                [self getLogLevelsForLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT],
                                [self getLogLevelsForLogType:XLOGGER_TYPE_ONLINE_SERVICES]];
        return allLoggers;
    }
    
    XLogObject *level_Simple     = [XcodeLogger getXLogObjectForType:paramLogType
                                                           withLevel:XLOGGER_LEVEL_SIMPLE];
    XLogObject *level_NH         = [XcodeLogger getXLogObjectForType:paramLogType
                                                           withLevel:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    XLogObject *level_INFO       = [XcodeLogger getXLogObjectForType:paramLogType
                                                           withLevel:XLOGGER_LEVEL_INFORMATION];
    XLogObject *level_IMPORTANT  = [XcodeLogger getXLogObjectForType:paramLogType
                                                           withLevel:XLOGGER_LEVEL_IMPORTANT];
    XLogObject *level_WARNING    = [XcodeLogger getXLogObjectForType:paramLogType
                                                           withLevel:XLOGGER_LEVEL_WARNING];
    XLogObject *level_ERROR      = [XcodeLogger getXLogObjectForType:paramLogType
                                                           withLevel:XLOGGER_LEVEL_ERROR];
    NSArray *logLevels = @[level_Simple,
                           level_NH,
                           level_INFO,
                           level_IMPORTANT,
                           level_WARNING,
                           level_ERROR];
    
    return logLevels;
}

+ (BOOL)filterOutputForXLogLevel:(NSNumber *)paramLogLevel
                     andFileName:(NSString *)paramFileName {
    
    BOOL allowOutput = NO;
    
    NSArray *logLevels = [XL_FILTERS_DICTIONARY[XL_GLOBAL_FILTER_STRING] copy];
    
    NSLog(@"%@", logLevels);
    
    if (!logLevels) {
        logLevels = [XL_FILTERS_DICTIONARY[[paramFileName uppercaseString]] copy];
    }
    
    if (logLevels) {
        if ([logLevels containsObject:paramLogLevel]) {
            allowOutput = YES;
        }
    } else {
        allowOutput = YES;
    }
    
    return allowOutput;
}

#pragma mark - Singleton Specific
static XcodeLogger *_sharedInstance = nil;
static bool isFirstAccess = YES;

+ (XcodeLogger *)sharedManager {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        
        _sharedInstance = [[super allocWithZone:NULL] init];
        
        COLORS_ENABLED = [self checkXcodeColorsPluginIsEnabled];
        
        [_sharedInstance loadColorThemeWithName:XLCT_DEFAULT_LIGHT_THEME];
    });
    
    return _sharedInstance;
}

- (id) init
{
    if(_sharedInstance){
        return _sharedInstance;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    return self;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self sharedManager];
}

- (id)copy
{
    return [[XcodeLogger alloc] init];
}

- (id)mutableCopy
{
    return [[XcodeLogger alloc] init];
}


#pragma mark - Lazy Init
- (NSMutableDictionary *)xLogInstances {
    if (!_xLogInstances) {
        _xLogInstances = [[NSMutableDictionary alloc] init];
    }
    return _xLogInstances;
}


@end


#pragma mark - Output
void setHeaderArguments (id callee,
                         const char *calleeMethod,
                         const char *fileName,
                         int lineNumber)
{
    if (callee) {
        NSDate *currentTime = [NSDate date];
        
        static NSDateFormatter *dateFormatter;
        
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:TIMESTAMP_FORMAT];
        }
        
        XL_HEADER_TIMESTAMP     = [dateFormatter stringFromDate: currentTime];
        XL_HEADER_CALLEE        = [NSString stringWithFormat:@"%p", callee];
        XL_HEADER_CALLEE_METHOD = [NSString stringWithUTF8String:calleeMethod];
        XL_HEADER_LINE_NUMBER   = [NSString stringWithFormat:@"%d", lineNumber];
    }
    // an exception for _NH to support per file filters
    XL_HEADER_FILE_NAME     = [[NSString stringWithUTF8String:fileName] lastPathComponent];
    
}

void  func_XLog_Output(XLOGGER_TYPE  paramLogType,
                       XLOGGER_LEVEL paramLogLevel,
                       id callee,
                       const char *calleeMethod,
                       const char *fileName,
                       int lineNumber,
                       NSString *inputBody, ...)
{
    
    @autoreleasepool {
        
        XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramLogType
                                                            withLevel:paramLogLevel];
        
        BOOL outputAllowed = NO;
        
        if (paramLogType == XLOGGER_TYPE_NSLOG_REPLACEMENT) {
            outputAllowed = YES;
        } else {
            
            if (!currentLogger.buildScheme) {
                NSString *error;
                
                switch (paramLogType) {
                    case XLOGGER_TYPE_DEBUG:
                        error = [NSString stringWithFormat:@"NO BUILD SCHEME WAS DEFINED FOR <DLog>!\nSet one using \"-[setBuildSchemeName:forXLogType:]\""];
                        break;
                    case XLOGGER_TYPE_DEVELOPMENT:
                        error = [NSString stringWithFormat:@"NO BUILD SCHEME WAS DEFINED FOR <DVLog>!\nSet one using \"-[setBuildSchemeName:forXLogType:]\""];
                        break;
                    default:
                        error = [NSString stringWithFormat:@"NO BUILD SCHEME WAS DEFINED FOR <%@>! Set one using \"-[setBuildSchemeName:forXLogType:]\"", currentLogger.logDescription];
                        break;
                }
                XLog_NH(@"%@", [XcodeLogger xLogFormattedStringFromString:error withColorFormat:nil]);
                return;
            }
            
            outputAllowed = [XcodeLogger currentRunningSchemeMatches:currentLogger.buildScheme
                                                         forXLogType:paramLogType];
        }
        
        // is there green light from build scheme?
        if (outputAllowed) {
            setHeaderArguments(callee,calleeMethod,fileName,lineNumber);
            NSNumber *currentLogLevel = [NSNumber numberWithUnsignedInt:[currentLogger logLevel]];
            outputAllowed = [XcodeLogger filterOutputForXLogLevel:currentLogLevel
                                                      andFileName:XL_HEADER_FILE_NAME];
        }
        
        // is there green light from build scheme & level filter?
        if (outputAllowed) {
            
            va_list args;
            va_start(args, inputBody);
            
            XLOG_OUTPUT_STRING = [[NSString alloc] initWithFormat:inputBody arguments:args];
            
            va_end(args);
            NSString *header   = [XcodeLogger populateFormatString:currentLogger.headerFormat
                                                     withArguments:currentLogger.headerArguments];
            
            XLOG_OUTPUT_STRING = [XcodeLogger xLogFormattedStringFromString:XLOG_OUTPUT_STRING
                                                            withColorFormat:currentLogger.outputColor];
            
            if (header) {
                //after header, add new line(s) before output body
                XLOG_OUTPUT_STRING = [header stringByAppendingString:[NSString stringWithFormat:@"%@%@",
                                                                      currentLogger.newlinesAfterHeader,
                                                                      XLOG_OUTPUT_STRING]];
            }
            XLOG_OUTPUT_STRING = [XLOG_OUTPUT_STRING stringByAppendingString:currentLogger.newlinesAfterOutput];
            [[NSFileHandle fileHandleWithStandardOutput] writeData: [XLOG_OUTPUT_STRING dataUsingEncoding: NSUTF8StringEncoding]];
        }
    }
}

