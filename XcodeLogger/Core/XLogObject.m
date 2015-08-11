//
//  XLogObject.m
//  XcodeLogger
//
/*  
*  Created by Razvan Alin Tanase on 13/07/15.
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

#import "XLogObject.h"

#define XLogType_Key(x)  [NSNumber numberWithUnsignedInt:x]
#define XLogLevel_Key(x) [NSNumber numberWithUnsignedInt:x]


static NSString *const DEFAULT_HEADER_FORMAT             = @"(%@)=> [>%@<]:%@:[#%@]:[> %@ <]";
static NSString *const DEFAULT_HEADER_FORMAT_SCHEME_LOGS = @"[%@](%@)=> [>%@<]:%@:[#%@]:[> %@ <]";

static NSString *const DEFAULT_TEXT_COLOR_NO_BACKGROUND = @"fg0,0,255;";

static NSString *const DEFAULT_TEXT_COLOR_INFO_LEVEL = @"fg255,255,255;";
static NSString *const DEFAULT_BGRD_COLOR_INFO_LEVEL = @"bg204,0,204;";

static NSString *const DEFAULT_TEXT_COLOR_HIGHLIGHT_LEVEL = @"fg255,255,255;";
static NSString *const DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL = @"bg0,102,51;";

static NSString *const DEFAULT_TEXT_COLOR_WARNING_LEVEL = @"fg0,0,0;";
static NSString *const DEFAULT_BGRD_COLOR_WARNING_LEVEL = @"bg255,255,0;";

static NSString *const DEFAULT_TEXT_COLOR_ERROR_LEVEL = @"fg255,255,255;";
static NSString *const DEFAULT_BGRD_COLOR_ERROR_LEVEL = @"bg255,0,0;";

static NSString *const DEFAULT_STATUS_TEXT_COLOR_WARNING = @"bg255,98,0;";

static NSString *const STATUS_DLOG_SIMPLE    = @"DEBUG";
static NSString *const STATUS_DLOG_INFO      = @"DEBUG:INFO";
static NSString *const STATUS_DLOG_HIGHLIGHT = @"DEBUG:STATUS";
static NSString *const STATUS_DLOG_WARNING   = @"DEBUG:WARNING";
static NSString *const STATUS_DLOG_ERROR     = @"DEBUG:ERROR";

static NSString *const STATUS_DVLOG_SIMPLE    = @"DEVELOPMENT";
static NSString *const STATUS_DVLOG_INFO      = @"DEVELOPMENT:INFO";
static NSString *const STATUS_DVLOG_HIGHLIGHT = @"DEVELOPMENT:STATUS";
static NSString *const STATUS_DVLOG_WARNING   = @"DEVELOPMENT:WARNING";
static NSString *const STATUS_DVLOG_ERROR     = @"DEVELOPMENT:ERROR";

static NSString *const STATUS_DDLOG_SIMPLE    = @"DBG&DEV";
static NSString *const STATUS_DDLOG_INFO      = @"DBG&DEV:INFO";
static NSString *const STATUS_DDLOG_HIGHLIGHT = @"DBG&DEV:STATUS";
static NSString *const STATUS_DDLOG_WARNING   = @"DBG&DEV:WARNING";
static NSString *const STATUS_DDLOG_ERROR     = @"DBG&DEV:ERROR";

static NSString *const STATUS_OLOG_SIMPLE    = @"ONLINE";
static NSString *const STATUS_OLOG_INFO      = @"ONLINE:INFO";
static NSString *const STATUS_OLOG_HIGHLIGHT = @"ONLINE:STATUS";
static NSString *const STATUS_OLOG_WARNING   = @"ONLINE:WARNING";
static NSString *const STATUS_OLOG_ERROR     = @"ONLINE:ERROR";

static NSString *const key_Status_Color = @"status_color";

@interface XLogObject ()
{
    XLOGGER_LEVEL _logLevel;
    NSUInteger _numberOfNewLinesAfterHeader;
    NSUInteger _numberOfNewLinesAfterOutput;
}

@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) NSString *buildScheme;
@property (nonatomic, readwrite) NSString *outputColor;
@property (nonatomic, readwrite) NSString *newlinesAfterHeader;
@property (nonatomic, readwrite) NSString *newlinesAfterOutput;

@property (nonatomic, copy) NSString *textColor;
@property (nonatomic, copy) NSString *backgroundColor;

@end

@implementation XLogObject

- (instancetype)init {
    [NSException raise:@"XLogObject Safe Initialization"
                format:@"Use -[initWithLogType:level:] instead of -[init]!"];
    return nil;
}

- (instancetype)initWithLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
{
    if (self = [super init]) {
        
        _type     = [self stringFromType:paramLogType];
        _logLevel = paramLogLevel;
        
        _newlinesAfterHeader = @"\n";
        _newlinesAfterOutput = @"\n\n";
        
        _outputColor = [self outputColorForLevel:paramLogLevel];
        
        switch (paramLogType) {
            case XLOGGER_TYPE_NSLOG:
            {
                if (paramLogLevel != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                    _headerFormat    = DEFAULT_HEADER_FORMAT;
                    _headerArguments = @[XL_ARG_TIMESTAMP,
                                         XL_ARG_CALLEE_ADDRESS,
                                         XL_ARG_FILE_NAME,
                                         XL_ARG_LINE_NUMBER,
                                         XL_ARG_CALLEE_METHOD];
                }
            }
                break;
            default:
            {
                if (paramLogLevel != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
                    _headerFormat    = DEFAULT_HEADER_FORMAT_SCHEME_LOGS;
                    _headerArguments = @[[self defaultStatusMessageForLogType:paramLogType
                                                                        level:paramLogLevel],
                                         XL_ARG_TIMESTAMP,
                                         XL_ARG_CALLEE_ADDRESS,
                                         XL_ARG_FILE_NAME,
                                         XL_ARG_LINE_NUMBER,
                                         XL_ARG_CALLEE_METHOD];
                }
            }
                break;
        }
        
        if (paramLogType == XLOGGER_TYPE_DEBUG_DEVELOPMENT) {
            _buildScheme = @"sharedScheme";
        }
    }
    return self;
}

- (void)setBuildScheme:(NSString *)buildScheme {
    _buildScheme = buildScheme;
}

- (NSString *)outputColor {
    if (!_outputColor) {
        _outputColor = [self outputColorForLevel:_logLevel];
    }
    return _outputColor;
}

- (void)setTextColorWithRed:(NSUInteger)red
                      Green:(NSUInteger)green
                       Blue:(NSUInteger)blue
{
    [self setOutputColor:nil];
    self.textColor = [NSString stringWithFormat:@"fg%tu,%tu,%tu;",red,green,blue];
}

- (void)setBackgroundColorWithRed:(NSUInteger)red
                            Green:(NSUInteger)green
                             Blue:(NSUInteger)blue
{
    [self setOutputColor:nil];
    self.backgroundColor = [NSString stringWithFormat:@"bg%tu,%tu,%tu;",red,green,blue];
}

-(void)setNumberOfNewLinesAfterHeader:(NSUInteger)numberOfNewLinesAfterHeader
{
    if (numberOfNewLinesAfterHeader == 0) {
        self.newlinesAfterHeader = @" ";
    } else {
        self.newlinesAfterHeader = @"";
        for (int index = 1; index <= numberOfNewLinesAfterHeader; index++) {
            self.newlinesAfterHeader = [self.newlinesAfterHeader stringByAppendingString:@"\n"];
        }
    }
}

- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)numberOfNewLinesAfterOutput
{
    if (numberOfNewLinesAfterOutput == 0) {
        self.newlinesAfterOutput = @"";
    } else {
        self.newlinesAfterOutput = @"";
        for (int index = 1; index <= numberOfNewLinesAfterOutput; index++) {
            self.newlinesAfterOutput = [self.newlinesAfterOutput stringByAppendingString:@"\n"];
        }
    }
}

#pragma mark - Private Helpers

- (NSDictionary *)getDefaultStatusInformations {
    
    static NSDictionary *defaultStatusInformations;
    
    if (!defaultStatusInformations) {
        NSDictionary *logLevelsStatusColors;
        logLevelsStatusColors = @{XLogLevel_Key(XLOGGER_LEVEL_INFORMATION):DEFAULT_BGRD_COLOR_INFO_LEVEL,
                                  XLogLevel_Key(XLOGGER_LEVEL_HIGHLIGHT)  :DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL,
                                  XLogLevel_Key(XLOGGER_LEVEL_WARNING)    :DEFAULT_STATUS_TEXT_COLOR_WARNING,
                                  XLogLevel_Key(XLOGGER_LEVEL_ERROR)      :DEFAULT_BGRD_COLOR_ERROR_LEVEL};
        
        NSDictionary *dLogLevelsStatusMessages;
        dLogLevelsStatusMessages = @{XLogLevel_Key(XLOGGER_LEVEL_SIMPLE)     :STATUS_DLOG_SIMPLE,
                                     XLogLevel_Key(XLOGGER_LEVEL_INFORMATION):STATUS_DLOG_INFO,
                                     XLogLevel_Key(XLOGGER_LEVEL_HIGHLIGHT)  :STATUS_DLOG_HIGHLIGHT,
                                     XLogLevel_Key(XLOGGER_LEVEL_WARNING)    :STATUS_DLOG_WARNING,
                                     XLogLevel_Key(XLOGGER_LEVEL_ERROR)      :STATUS_DLOG_ERROR};
        
        NSDictionary *dvLogLevelsStatusMessages;
        dvLogLevelsStatusMessages = @{XLogLevel_Key(XLOGGER_LEVEL_SIMPLE)     :STATUS_DVLOG_SIMPLE,
                                      XLogLevel_Key(XLOGGER_LEVEL_INFORMATION):STATUS_DVLOG_INFO,
                                      XLogLevel_Key(XLOGGER_LEVEL_HIGHLIGHT)  :STATUS_DVLOG_HIGHLIGHT,
                                      XLogLevel_Key(XLOGGER_LEVEL_WARNING)    :STATUS_DVLOG_WARNING,
                                      XLogLevel_Key(XLOGGER_LEVEL_ERROR)      :STATUS_DVLOG_ERROR};
        
        NSDictionary *ddLogLevelsStatusMessages;
        ddLogLevelsStatusMessages = @{XLogLevel_Key(XLOGGER_LEVEL_SIMPLE)     :STATUS_DDLOG_SIMPLE,
                                      XLogLevel_Key(XLOGGER_LEVEL_INFORMATION):STATUS_DDLOG_INFO,
                                      XLogLevel_Key(XLOGGER_LEVEL_HIGHLIGHT)  :STATUS_DDLOG_HIGHLIGHT,
                                      XLogLevel_Key(XLOGGER_LEVEL_WARNING)    :STATUS_DDLOG_WARNING,
                                      XLogLevel_Key(XLOGGER_LEVEL_ERROR)      :STATUS_DDLOG_ERROR};
        
        NSDictionary *oLogLevelsStatusMessages;
        oLogLevelsStatusMessages = @{XLogLevel_Key(XLOGGER_LEVEL_SIMPLE)     :STATUS_OLOG_SIMPLE,
                                     XLogLevel_Key(XLOGGER_LEVEL_INFORMATION):STATUS_OLOG_INFO,
                                     XLogLevel_Key(XLOGGER_LEVEL_HIGHLIGHT)  :STATUS_OLOG_HIGHLIGHT,
                                     XLogLevel_Key(XLOGGER_LEVEL_WARNING)    :STATUS_OLOG_WARNING,
                                     XLogLevel_Key(XLOGGER_LEVEL_ERROR)      :STATUS_OLOG_ERROR};
        
        defaultStatusInformations = @{key_Status_Color                            :logLevelsStatusColors,
                                      XLogType_Key(XLOGGER_TYPE_DEBUG)            :dLogLevelsStatusMessages,
                                      XLogType_Key(XLOGGER_TYPE_DEVELOPMENT)      :dvLogLevelsStatusMessages,
                                      XLogType_Key(XLOGGER_TYPE_DEBUG_DEVELOPMENT):ddLogLevelsStatusMessages,
                                      XLogType_Key(XLOGGER_TYPE_ONLINE_SERVICES)  :oLogLevelsStatusMessages};
        
    }
    
    return defaultStatusInformations;
}

- (BOOL)xcodeColorsPluginIsEnabled {
    
    static NSString *xcEnabledString;
    
    if (!xcEnabledString) {
        char *xcode_colors = getenv("XcodeColors");
        xcEnabledString = xcode_colors && (strcmp(xcode_colors, "YES") == 0) ? @"YES":@"NO";
    }
    
    return [xcEnabledString boolValue];
}

- (NSString *)convertBackgroundColorToText:(NSString *)colorString
{
    return [colorString stringByReplacingOccurrencesOfString:@"bg"
                                                  withString:[NSString stringWithFormat:@"%@fg",XCODE_COLORS_ESCAPE]];
}

- (NSString *)stringFromType:(XLOGGER_TYPE)paramXLogType
{
    switch (paramXLogType) {
        case XLOGGER_TYPE_NSLOG:
            return @"XLOGGER_TYPE_NSLOG";
            break;
        case XLOGGER_TYPE_DEBUG:
            return @"XLOGGER_TYPE_DEBUG";
            break;
        case XLOGGER_TYPE_DEVELOPMENT:
            return @"XLOGGER_TYPE_DEVELOPMENT";
            break;
        case XLOGGER_TYPE_DEBUG_DEVELOPMENT:
            return @"XLOGGER_TYPE_DEBUG_DEVELOPMENT";
            break;
        case XLOGGER_TYPE_ONLINE_SERVICES:
            return @"XLOGGER_TYPE_ONLINE_SERVICES";
            break;
        default:
            break;
    }
    return nil;
}

- (NSString *)outputColorForLevel:(XLOGGER_LEVEL)paramLevel
{
    if (!self.textColor && !self.backgroundColor)
    {
        switch (paramLevel) {
            case XLOGGER_LEVEL_INFORMATION:
                return [NSString stringWithFormat:@"%@%@%@%@",
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_TEXT_COLOR_INFO_LEVEL,
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_BGRD_COLOR_INFO_LEVEL];
                break;
            case XLOGGER_LEVEL_HIGHLIGHT:
                return [NSString stringWithFormat:@"%@%@%@%@",
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_TEXT_COLOR_HIGHLIGHT_LEVEL,
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL];
                break;
            case XLOGGER_LEVEL_WARNING:
                return [NSString stringWithFormat:@"%@%@%@%@",
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_TEXT_COLOR_WARNING_LEVEL,
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_BGRD_COLOR_WARNING_LEVEL];
                break;
            case XLOGGER_LEVEL_ERROR:
                return [NSString stringWithFormat:@"%@%@%@%@",
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_TEXT_COLOR_ERROR_LEVEL,
                        XCODE_COLORS_ESCAPE,
                        DEFAULT_BGRD_COLOR_ERROR_LEVEL];
                break;
            default:
                return [NSString stringWithFormat:@"%@%@",XCODE_COLORS_ESCAPE, DEFAULT_TEXT_COLOR_NO_BACKGROUND];
                break;
        }
    } // if (!self.textColor && !self.backgroundColor) {
    else if (self.textColor && self.backgroundColor)
    {
        return [NSString stringWithFormat:@"%@%@%@%@",
                XCODE_COLORS_ESCAPE,
                self.textColor,
                XCODE_COLORS_ESCAPE,
                self.backgroundColor];
    }
    
    if (self.textColor) {
        return [NSString stringWithFormat:@"%@%@",XCODE_COLORS_ESCAPE,self.textColor];
    }
    
    if (self.backgroundColor) {
        return [NSString stringWithFormat:@"%@%@",XCODE_COLORS_ESCAPE,self.backgroundColor];
    }
    
    return nil;
}

- (NSString *)defaultStatusMessageForLogType:(XLOGGER_TYPE)paramXLogType level:(XLOGGER_LEVEL)paramXLogLevel
{
    
    NSDictionary *statusDictionary = [self getDefaultStatusInformations];
    
    NSString *statusMessage = statusDictionary[XLogType_Key(paramXLogType)][XLogLevel_Key(paramXLogLevel)];
    NSString *statusColor   = statusDictionary[key_Status_Color][XLogLevel_Key(paramXLogLevel)];

    switch (paramXLogLevel) {
        case XLOGGER_LEVEL_SIMPLE:
            return statusMessage;
            break;
        default:
        {
            if ([self xcodeColorsPluginIsEnabled]) {
                return [NSString stringWithFormat:@"%@%@%@",
                        [self convertBackgroundColorToText:statusColor],
                        statusMessage,
                        XCODE_COLORS_RESET];
            } else {
                return statusMessage;
            }
        }
            break;
    }
    return nil;
}

@end
