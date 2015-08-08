//
//  XcodeLogger.m
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 02/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import "XcodeLogger.h"
#import "XLogObject.h"

static XcodeLogger *_sharedInstance = nil;

static NSString *TIMESTAMP_FORMAT = @"HH:mm:ss";

static NSString *KEY_INFO_PLIST_SCHEME;

static NSString *XL_HEADER_TIMESTAMP;
static NSString *XL_HEADER_CALLEE;
static NSString *XL_HEADER_FILE_NAME;
static NSString *XL_HEADER_LINE_NUMBER;
static NSString *XL_HEADER_CALLEE_METHOD;

static NSString *XLOG_OUTPUT_STRING;

static NSString *DLOG_BUILD_SCHEME_NAME;
static NSString *DVLOG_BUILD_SCHEME_NAME;

static BOOL XCOLORS_ENABLED = NO;
static BOOL COLORS_ENABLED  = YES;

#pragma mark - XCODE LOGGER
@interface XcodeLogger ()

//NSLOG REPLACEMENT - SCHEME INDEPENDENT
@property (nonatomic, strong) XLogObject *xLog;
@property (nonatomic, strong) XLogObject *xLog_NH;
@property (nonatomic, strong) XLogObject *xLog_INFO;
@property (nonatomic, strong) XLogObject *xLog_HIGHLIGHT;
@property (nonatomic, strong) XLogObject *xLog_WARNING;
@property (nonatomic, strong) XLogObject *xLog_ERROR;

//LOGGER FOR A DEBUG SCHEME
@property (nonatomic, strong) XLogObject *dLog;
@property (nonatomic, strong) XLogObject *dLog_NH;
@property (nonatomic, strong) XLogObject *dLog_INFO;
@property (nonatomic, strong) XLogObject *dLog_HIGHLIGHT;
@property (nonatomic, strong) XLogObject *dLog_WARNING;
@property (nonatomic, strong) XLogObject *dLog_ERROR;

//LOGGER FOR A DEVELOPMENT SCHEME
@property (nonatomic, strong) XLogObject *dvLog;
@property (nonatomic, strong) XLogObject *dvLog_NH;
@property (nonatomic, strong) XLogObject *dvLog_INFO;
@property (nonatomic, strong) XLogObject *dvLog_HIGHLIGHT;
@property (nonatomic, strong) XLogObject *dvLog_WARNING;
@property (nonatomic, strong) XLogObject *dvLog_ERROR;

//LOGGER FOR BOTH DEBUG & DEVELOPMENT SCHEMES
@property (nonatomic, strong) XLogObject *ddLog;
@property (nonatomic, strong) XLogObject *ddLog_NH;
@property (nonatomic, strong) XLogObject *ddLog_INFO;
@property (nonatomic, strong) XLogObject *ddLog_HIGHLIGHT;
@property (nonatomic, strong) XLogObject *ddLog_WARNING;
@property (nonatomic, strong) XLogObject *ddLog_ERROR;

//LOGGER FOR ONLINE SERVICES
@property (nonatomic, strong) XLogObject *oLog;
@property (nonatomic, strong) XLogObject *oLog_NH;
@property (nonatomic, strong) XLogObject *oLog_INFO;
@property (nonatomic, strong) XLogObject *oLog_HIGHLIGHT;
@property (nonatomic, strong) XLogObject *oLog_WARNING;
@property (nonatomic, strong) XLogObject *oLog_ERROR;

@end

@implementation XcodeLogger

#pragma mark - Public Methods

#pragma mark Build Schemes
- (void)setInfoPlistKeyNameForRunningSchemes:(NSString *)paramRunningSchemeKey {
    KEY_INFO_PLIST_SCHEME = paramRunningSchemeKey;
}

- (void)setBuildSchemeName:(NSString *)paramSchemeName
               forXLogType:(XLOGGER_TYPE)paramXLogType
{
    switch (paramXLogType) {
        case XLOGGER_TYPE_NSLOG:
            [NSException raise:@"XcodeLogger Build Schemes Initializer"
                        format:@"Do not set a build scheme for XLog!\nThe idea is that XLog is a 1:1 replacement for NSLog's behaviour."];
            break;
        case XLOGGER_TYPE_DEBUG_DEVELOPMENT:
            [NSException raise:@"XcodeLogger Build Schemes Initializer"
                        format:@"Do not set a build scheme for DDLog!\nIts output rules are dependent on whether there are build schemes defined for DLog and/or DVLog."];
            break;
        default:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramXLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setBuildScheme:paramSchemeName];
            }
        }
            break;
    }
    
    switch (paramXLogType) {
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

#pragma mark Format
- (void)setHeaderForXLogType:(XLOGGER_TYPE)paramXLogType
                       level:(XLOGGER_LEVEL)paramXLogLevel
                      format:(NSString *)paramHeaderFormat
                   arguments:(NSArray *)paramArguments
{
    
    switch (paramXLogLevel) {
        case XLOGGER_ALL_LEVELS:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramXLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setHeaderFormat:paramHeaderFormat];
                [logLevel setHeaderArguments:paramArguments];
            }
        }
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramXLogType
                                                                withLevel:paramXLogLevel];
            [currentLogger setHeaderFormat:paramHeaderFormat];
            [currentLogger setHeaderArguments:paramArguments];
        }
            break;
    }
}

- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramXLogType
                                 level:(XLOGGER_LEVEL)paramXLogLevel
{
    switch (paramXLogLevel) {
        case XLOGGER_ALL_LEVELS:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramXLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setNumberOfNewLinesAfterHeader:paramNumberOfLines];
            }
        }
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramXLogType
                                                                withLevel:paramXLogLevel];
            [currentLogger setNumberOfNewLinesAfterHeader:paramNumberOfLines];
        }
            break;
    }
}

- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramXLogType
                                 level:(XLOGGER_LEVEL)paramXLogLevel
{
    switch (paramXLogLevel) {
        case XLOGGER_ALL_LEVELS:
        {
            NSArray *logLevels = [XcodeLogger getLogLevelsForLogType:paramXLogType];
            for (XLogObject *logLevel in logLevels) {
                [logLevel setNumberOfNewLinesAfterOutput:paramNumberOfLines];
            }
        }
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramXLogType
                                                                withLevel:paramXLogLevel];
            [currentLogger setNumberOfNewLinesAfterOutput:paramNumberOfLines];
        }
            break;
    }
}

-(void)setTimestampFormat:(NSString *)paramTimestampFormat {
    TIMESTAMP_FORMAT = paramTimestampFormat;
}

#pragma mark Colors
- (void)setColorLogsEnabled:(BOOL)paramEnableColors {
    COLORS_ENABLED = paramEnableColors;
}

- (void)setTextColorForXLogType:(XLOGGER_TYPE)paramXLogType
                          level:(XLOGGER_LEVEL)paramXLogLevel
                        withRed:(NSUInteger)red
                          Green:(NSUInteger)green
                           Blue:(NSUInteger)blue
{
    switch (paramXLogLevel) {
        case XLOGGER_ALL_LEVELS:
            [NSException raise:@"XcodeLogger Set Text Color"
                        format:@"-[setTextColorForXLogType...] operation is unavailable for XLOGGER_ALL_LEVELS.\nSelect a specific Log Level instead."];
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramXLogType
                                                                withLevel:paramXLogLevel];
            [currentLogger setTextColorWithRed:red Green:green Blue:blue];
        }
            break;
    }
}

- (void)setBackgroundColorForXLogType:(XLOGGER_TYPE)paramXLogType
                                level:(XLOGGER_LEVEL)paramXLogLevel
                              withRed:(NSUInteger)red
                                Green:(NSUInteger)green
                                 Blue:(NSUInteger)blue
{
    switch (paramXLogLevel) {
        case XLOGGER_ALL_LEVELS:
            [NSException raise:@"XcodeLogger Set Background Color"
                        format:@"-[setBackgroundColorForXLogType...] operation is unavailable for XLOGGER_ALL_LEVELS.\nSelect a specific Log Level instead."];
            break;
            
        default:
        {
            XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramXLogType
                                                                withLevel:paramXLogLevel];
            [currentLogger setBackgroundColorWithRed:red Green:green Blue:blue];
        }
            break;
    }
}

#pragma mark - Private Helpers
+ (BOOL)isXcodeColorsPluginEnabled {
    char *xcode_colors = getenv("XcodeColors");
    return xcode_colors && (strcmp(xcode_colors, "YES") == 0);
}

+ (BOOL)currentRunningSchemeMatches:(NSString *)paramBuildScheme
                        forXLogType:(XLOGGER_TYPE)paramXLogType
{
    NSString *currentRunningScheme = [(NSString *)[[[NSBundle mainBundle] infoDictionary]
                                                   valueForKey:KEY_INFO_PLIST_SCHEME] uppercaseString];
    
    NSString *buildScheme = [paramBuildScheme uppercaseString];
    
    switch (paramXLogType) {
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

+ (NSString *)xLogFormattedStringFromString:(NSString *)paramString
                            withColorFormat:(NSString *)paramColorFormat {
    
    if (XCOLORS_ENABLED && COLORS_ENABLED) {
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
                    XLog_NH(@"UNKNOWN ARGUMENT TYPE! CHECK ");
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


+ (XLogObject *)getXLogObjectForType:(XLOGGER_TYPE)paramXLogType withLevel:(XLOGGER_LEVEL)paramXLogLevel
{
    switch (paramXLogType)
    {
        case XLOGGER_TYPE_NSLOG:
        {
            switch (paramXLogLevel)
            {
                case XLOGGER_LEVEL_SIMPLE:
                    return [XcodeLogger sharedManager].xLog;
                    break;
                case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
                    return [XcodeLogger sharedManager].xLog_NH;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [XcodeLogger sharedManager].xLog_INFO;
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [XcodeLogger sharedManager].xLog_HIGHLIGHT;
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [XcodeLogger sharedManager].xLog_WARNING;
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [XcodeLogger sharedManager].xLog_ERROR;
                    break;
                default:
                    break;
            }
        }
            break;
        case XLOGGER_TYPE_DEBUG:
        {
            switch (paramXLogLevel)
            {
                case XLOGGER_LEVEL_SIMPLE:
                    return [XcodeLogger sharedManager].dLog;
                    break;
                case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
                    return [XcodeLogger sharedManager].dLog_NH;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [XcodeLogger sharedManager].dLog_INFO;
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [XcodeLogger sharedManager].dLog_HIGHLIGHT;
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [XcodeLogger sharedManager].dLog_WARNING;
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [XcodeLogger sharedManager].dLog_ERROR;
                    break;
                default:
                    break;
            }
        }
            break;
        case XLOGGER_TYPE_DEVELOPMENT:
        {
            switch (paramXLogLevel)
            {
                case XLOGGER_LEVEL_SIMPLE:
                    return [XcodeLogger sharedManager].dvLog;
                    break;
                case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
                    return [XcodeLogger sharedManager].dvLog_NH;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [XcodeLogger sharedManager].dvLog_INFO;
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [XcodeLogger sharedManager].dvLog_HIGHLIGHT;
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [XcodeLogger sharedManager].dvLog_WARNING;
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [XcodeLogger sharedManager].dvLog_ERROR;
                    break;
                default:
                    break;
            }
        }
            break;
        case XLOGGER_TYPE_DEBUG_DEVELOPMENT:
        {
            switch (paramXLogLevel)
            {
                case XLOGGER_LEVEL_SIMPLE:
                    return [XcodeLogger sharedManager].ddLog;
                    break;
                case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
                    return [XcodeLogger sharedManager].ddLog_NH;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [XcodeLogger sharedManager].ddLog_INFO;
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [XcodeLogger sharedManager].ddLog_HIGHLIGHT;
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [XcodeLogger sharedManager].ddLog_WARNING;
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [XcodeLogger sharedManager].ddLog_ERROR;
                    break;
                default:
                    break;
            }
        }
            break;
        case XLOGGER_TYPE_ONLINE_SERVICES:
        {
            switch (paramXLogLevel)
            {
                case XLOGGER_LEVEL_SIMPLE:
                    return [XcodeLogger sharedManager].oLog;
                    break;
                case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
                    return [XcodeLogger sharedManager].oLog_NH;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [XcodeLogger sharedManager].oLog_INFO;
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [XcodeLogger sharedManager].oLog_HIGHLIGHT;
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [XcodeLogger sharedManager].oLog_WARNING;
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [XcodeLogger sharedManager].oLog_ERROR;
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return nil;
}

+ (NSArray *)getLogLevelsForLogType:(XLOGGER_TYPE)paramXLogType
{
    XLogObject *level_Simple     = [XcodeLogger getXLogObjectForType:paramXLogType
                                                           withLevel:XLOGGER_LEVEL_SIMPLE];
    XLogObject *level_NH         = [XcodeLogger getXLogObjectForType:paramXLogType
                                                           withLevel:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    XLogObject *level_INFO       = [XcodeLogger getXLogObjectForType:paramXLogType
                                                           withLevel:XLOGGER_LEVEL_INFORMATION];
    XLogObject *level_HIGHLIGHT  = [XcodeLogger getXLogObjectForType:paramXLogType
                                                           withLevel:XLOGGER_LEVEL_HIGHLIGHT];
    XLogObject *level_WARNING    = [XcodeLogger getXLogObjectForType:paramXLogType
                                                           withLevel:XLOGGER_LEVEL_WARNING];
    XLogObject *level_ERROR      = [XcodeLogger getXLogObjectForType:paramXLogType
                                                           withLevel:XLOGGER_LEVEL_ERROR];
    
    return @[level_Simple,level_NH,level_INFO,
             level_HIGHLIGHT,level_WARNING,level_ERROR];
}


#pragma mark - Singleton Specific
static bool isFirstAccess = YES;

+ (XcodeLogger *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        XCOLORS_ENABLED = [self isXcodeColorsPluginEnabled];
        _sharedInstance = [[super allocWithZone:NULL] init];
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

#pragma mark - Lazy instantiation
#pragma mark XLOG
- (XLogObject *)xLog {
    if (!_xLog) {
        _xLog = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_NSLOG
                                              level:XLOGGER_LEVEL_SIMPLE];
    }
    return _xLog;
}
- (XLogObject *)xLog_NH {
    if (!_xLog_NH) {
        _xLog_NH = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_NSLOG
                                                 level:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    }
    return _xLog_NH;
}
- (XLogObject *)xLog_INFO {
    if (!_xLog_INFO) {
        _xLog_INFO = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_NSLOG
                                                   level:XLOGGER_LEVEL_INFORMATION];
    }
    return _xLog_INFO;
}
- (XLogObject *)xLog_HIGHLIGHT {
    if (!_xLog_HIGHLIGHT) {
        _xLog_HIGHLIGHT = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_NSLOG
                                                        level:XLOGGER_LEVEL_HIGHLIGHT];
    }
    return _xLog_HIGHLIGHT;
}
-(XLogObject *)xLog_WARNING {
    if (!_xLog_WARNING) {
        _xLog_WARNING = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_NSLOG
                                                      level:XLOGGER_LEVEL_WARNING];
    }
    return _xLog_WARNING;
}
- (XLogObject *)xLog_ERROR {
    if (!_xLog_ERROR) {
        _xLog_ERROR = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_NSLOG
                                                    level:XLOGGER_LEVEL_ERROR];
    }
    return _xLog_ERROR;
}

#pragma mark DLOG
- (XLogObject *)dLog {
    if (!_dLog) {
        _dLog = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG
                                              level:XLOGGER_LEVEL_SIMPLE];
    }
    return _dLog;
}
- (XLogObject *)dLog_NH {
    if (!_dLog_NH) {
        _dLog_NH = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG
                                                 level:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    }
    return _dLog_NH;
}
- (XLogObject *)dLog_INFO {
    if (!_dLog_INFO) {
        _dLog_INFO = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG
                                                   level:XLOGGER_LEVEL_INFORMATION];
    }
    return _dLog_INFO;
}
- (XLogObject *)dLog_HIGHLIGHT {
    if (!_dLog_HIGHLIGHT) {
        _dLog_HIGHLIGHT = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG
                                                        level:XLOGGER_LEVEL_HIGHLIGHT];
    }
    return _dLog_HIGHLIGHT;
}
- (XLogObject *)dLog_WARNING {
    if (!_dLog_WARNING) {
        _dLog_WARNING = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG
                                                      level:XLOGGER_LEVEL_WARNING];
    }
    return _dLog_WARNING;
}
- (XLogObject *)dLog_ERROR {
    if (!_dLog_ERROR) {
        _dLog_ERROR = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG
                                                    level:XLOGGER_LEVEL_ERROR];
    }
    return _dLog_ERROR;
}

#pragma mark DVLOG
- (XLogObject *)dvLog {
    if (!_dvLog) {
        _dvLog = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEVELOPMENT
                                               level:XLOGGER_LEVEL_SIMPLE];
    }
    return _dvLog;
}
- (XLogObject *)dvLog_NH {
    if (!_dvLog_NH) {
        _dvLog_NH = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEVELOPMENT
                                                  level:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    }
    return _dvLog_NH;
}
- (XLogObject *)dvLog_INFO {
    if (!_dvLog_INFO) {
        _dvLog_INFO = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEVELOPMENT
                                                    level:XLOGGER_LEVEL_INFORMATION];
    }
    return _dvLog_INFO;
}
- (XLogObject *)dvLog_HIGHLIGHT {
    if (!_dvLog_HIGHLIGHT) {
        _dvLog_HIGHLIGHT = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEVELOPMENT
                                                         level:XLOGGER_LEVEL_HIGHLIGHT];
    }
    return _dvLog_HIGHLIGHT;
}
- (XLogObject *)dvLog_WARNING {
    if (!_dvLog_WARNING) {
        _dvLog_WARNING = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEVELOPMENT
                                                       level:XLOGGER_LEVEL_WARNING];
    }
    return _dvLog_WARNING;
}
- (XLogObject *)dvLog_ERROR {
    if (!_dvLog_ERROR) {
        _dvLog_ERROR = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEVELOPMENT
                                                     level:XLOGGER_LEVEL_ERROR];
    }
    return _dvLog_ERROR;
}


#pragma mark DDLOG
- (XLogObject *)ddLog {
    if (!_ddLog) {
        _ddLog = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                               level:XLOGGER_LEVEL_SIMPLE];
    }
    return _ddLog;
}
- (XLogObject *)ddLog_NH {
    if (!_ddLog_NH) {
        _ddLog_NH = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                                  level:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    }
    return _ddLog_NH;
}
- (XLogObject *)ddLog_INFO {
    if (!_ddLog_INFO) {
        _ddLog_INFO = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                                    level:XLOGGER_LEVEL_INFORMATION];
    }
    return _ddLog_INFO;
}
- (XLogObject *)ddLog_HIGHLIGHT {
    if (!_ddLog_HIGHLIGHT) {
        _ddLog_HIGHLIGHT = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                                         level:XLOGGER_LEVEL_HIGHLIGHT];
    }
    return _ddLog_HIGHLIGHT;
}
- (XLogObject *)ddLog_WARNING {
    if (!_ddLog_WARNING) {
        _ddLog_WARNING = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                                       level:XLOGGER_LEVEL_WARNING];
    }
    return _dvLog_WARNING;
}
- (XLogObject *)ddLog_ERROR {
    if (!_ddLog_ERROR) {
        _ddLog_ERROR = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
                                                     level:XLOGGER_LEVEL_ERROR];
    }
    return _ddLog_ERROR;
}

#pragma mark OLOG
- (XLogObject *)oLog {
    if (!_oLog) {
        _oLog = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_ONLINE_SERVICES
                                              level:XLOGGER_LEVEL_SIMPLE];
    }
    return _oLog;
}
- (XLogObject *)oLog_NH {
    if (!_oLog_NH) {
        _oLog_NH = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_ONLINE_SERVICES
                                                 level:XLOGGER_LEVEL_SIMPLE_NO_HEADER];
    }
    return _oLog_NH;
}
- (XLogObject *)oLog_INFO {
    if (!_oLog_INFO) {
        _oLog_INFO = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_ONLINE_SERVICES
                                                   level:XLOGGER_LEVEL_INFORMATION];
    }
    return _oLog_INFO;
}
- (XLogObject *)oLog_HIGHLIGHT {
    if (!_oLog_HIGHLIGHT) {
        _oLog_HIGHLIGHT = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_ONLINE_SERVICES
                                                        level:XLOGGER_LEVEL_HIGHLIGHT];
    }
    return _oLog_HIGHLIGHT;
}
- (XLogObject *)oLog_WARNING {
    if (!_oLog_WARNING) {
        _oLog_WARNING = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_ONLINE_SERVICES
                                                      level:XLOGGER_LEVEL_WARNING];
    }
    return _oLog_WARNING;
}
- (XLogObject *)oLog_ERROR {
    if (!_oLog_ERROR) {
        _oLog_ERROR = [[XLogObject alloc] initWithLogType:XLOGGER_TYPE_ONLINE_SERVICES
                                                    level:XLOGGER_LEVEL_ERROR];
    }
    return _oLog_ERROR;
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
        XL_HEADER_FILE_NAME     = [[NSString stringWithUTF8String:fileName] lastPathComponent];
        XL_HEADER_LINE_NUMBER   = [NSString stringWithFormat:@"%d", lineNumber];
    }
}

void  func_XLog_Output(XLOGGER_TYPE  paramXLogType,
                       XLOGGER_LEVEL paramXLogLevel,
                       id callee,
                       const char *calleeMethod,
                       const char *fileName,
                       int lineNumber,
                       NSString *inputBody, ...)
{
    
    @autoreleasepool {
        
        XLogObject *currentLogger = [XcodeLogger getXLogObjectForType:paramXLogType
                                                            withLevel:paramXLogLevel];
        
        BOOL outputAllowed = NO;
        
        if (paramXLogType == XLOGGER_TYPE_NSLOG) {
            outputAllowed = YES;
        } else {
            
            if (!currentLogger.buildScheme) {
                
                NSString *error;
                
                switch (paramXLogType) {
                    case XLOGGER_TYPE_DEBUG:
                        error = [NSString stringWithFormat:@"NO BUILD SCHEME WAS DEFINED FOR <%@>!\n<DLog> & <DDLog> are disabled for the currently running scheme!\nSet one using \"-[setBuildSchemeName:forXLogType:]\"", currentLogger.type];
                        break;
                    case XLOGGER_TYPE_DEVELOPMENT:
                        error = [NSString stringWithFormat:@"NO BUILD SCHEME WAS DEFINED FOR <%@>\n*DVLog* & *DDLog* are disabled for the currently running scheme!\nSet one using \"-[setBuildSchemeName:forXLogType:]\"", currentLogger.type];
                        break;
                    default:
                        error = [NSString stringWithFormat:@"NO BUILD SCHEME WAS DEFINED FOR <%@>! Set one using \"-[setBuildSchemeName:forXLogType:]\"", currentLogger.type];
                        break;
                }
                
                
                XLog_NH(@"%@", [XcodeLogger xLogFormattedStringFromString:error withColorFormat:nil]);
                return;
            }
            
            outputAllowed = [XcodeLogger currentRunningSchemeMatches:currentLogger.buildScheme
                                                         forXLogType:paramXLogType];
        }
        
        if (outputAllowed) {
            
            va_list args;
            va_start(args, inputBody);
            
            setHeaderArguments(callee,calleeMethod,fileName,lineNumber);
            
            XLOG_OUTPUT_STRING = [[NSString alloc] initWithFormat:inputBody arguments:args];
            
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
            
            va_end(args);
            
        }
    }
}

