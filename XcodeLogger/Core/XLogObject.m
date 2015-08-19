//
//  XLogObject.m
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

#import "XLogObject.h"
#import "XLColorThemes.h"

#define XLog_Key(x)  [NSNumber numberWithUnsignedInt:x]

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
    XLOGGER_TYPE  _logType;
    XLOGGER_LEVEL _logLevel;
    NSUInteger _numberOfNewLinesAfterHeader;
    NSUInteger _numberOfNewLinesAfterOutput;
}

@property (nonatomic, strong) XLColorThemes *colorThemesManager;

@property (nonatomic, readwrite) NSString *logHeaderDescription;
@property (nonatomic, readwrite) NSString *logTypeString;
@property (nonatomic, readwrite) NSString *buildScheme;
@property (nonatomic, readwrite) NSString *outputColor;
@property (nonatomic, readwrite) NSString *newlinesAfterHeader;
@property (nonatomic, readwrite) NSString *newlinesAfterOutput;

@property (nonatomic, copy) NSString *textColorFormat;
@property (nonatomic, copy) NSString *backgroundColorFormat;

@property (nonatomic, copy) NSDictionary *colorThemeDictionary;

@property (nonatomic, assign) BOOL colorsEnabled;

@end

@implementation XLogObject

@synthesize logHeaderDescription = _logHeaderDescription;

#pragma mark - Init

- (instancetype)init {
    [NSException raise:@"XLogObject Safe Initialization"
                format:@"Use -[initWithLogType:level:] instead of -[init]!"];
    return nil;
}

- (instancetype)initWithLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                  colorsEnabled:(BOOL)paramColorsEnabled {
    
    if (self = [super init]) {
        
        _logType  = paramLogType;
        _logLevel = paramLogLevel;
        _logTypeString = [[self.class stringFromLogType: _logType]stringByAppendingString:[self.class stringFromLogLevel:_logLevel]];
        _colorsEnabled = paramColorsEnabled;
        
        self.colorThemesManager   = [XLColorThemes sharedManager];
        self.colorThemeDictionary = [self.colorThemesManager getColorThemeForType: _logType];
        
        _newlinesAfterHeader = @"\n";
        _newlinesAfterOutput = @"\n\n";
        
        switch (paramLogType) {
            case XLOGGER_TYPE_NSLOG_REPLACEMENT:
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
        
        if (_logType == XLOGGER_TYPE_DEBUG_DEVELOPMENT) {
            _buildScheme = @"sharedScheme";
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(colorThemeDidChange)
                                                     name:XL_THEME_DID_CHANGE_NOTIFICATION
                                                   object:self.colorThemesManager];
    }
    return self;
}

#pragma mark - PUBLIC

#pragma mark Scheme Linking
- (void)setBuildScheme:(NSString *)buildScheme {
    _buildScheme = buildScheme;
}

#pragma mark Informations
- (XLOGGER_TYPE)logType {
    return _logType;
}

- (XLOGGER_LEVEL)logLevel {
    return _logLevel;
}

#pragma mark Colors
- (NSString *)outputColor {
    _outputColor = [self outputColorForLevel:_logLevel];
    return _outputColor;
}

- (void)setTextColorWithRed:(NSUInteger)red
                      Green:(NSUInteger)green
                       Blue:(NSUInteger)blue
{
    [self setOutputColor:nil];
    self.textColorFormat = [NSString stringWithFormat:@"fg%tu,%tu,%tu;",red,green,blue];
}

- (void)setTextColor:(XLColor *)paramTextColor
{
    if (paramTextColor) {
        
        NSString *UIColorClass = @"UIColor";
        
        if ([paramTextColor isKindOfClass:[NSClassFromString(UIColorClass) class]]) {
            
            CGFloat red, green, blue;
            [paramTextColor getRed:&red green:&green blue:&blue alpha:NULL];
            
            [self setTextColorWithRed:(NSUInteger)(red   * 255.0)
                                Green:(NSUInteger)(green * 255.0)
                                 Blue:(NSUInteger)(blue  * 255.0)];
        } else {
#if !TARGET_OS_IPHONE
            NSColor *color = [paramTextColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
            
            NSUInteger red, green, blue;
            
            red   = (NSUInteger)([color redComponent]   * 255.0);
            green = (NSUInteger)([color greenComponent] * 255.0);
            blue  = (NSUInteger)([color blueComponent]  * 255.0);
            
            [self setTextColorWithRed:red Green:green Blue:blue];
#endif
        }
    }//if (paramTextColor) {
}

- (void)setBackgroundColorWithRed:(NSUInteger)red
                            Green:(NSUInteger)green
                             Blue:(NSUInteger)blue
{
    [self setOutputColor:nil];
    self.backgroundColorFormat = [NSString stringWithFormat:@"bg%tu,%tu,%tu;",red,green,blue];
}

- (void)setBackgroundColor:(XLColor *)paramBackgroundColor
{
    if (paramBackgroundColor) {
        NSString *UIColorClassString = @"UIColor";
        Class UIColorClass = NSClassFromString(UIColorClassString);
        
        if ([paramBackgroundColor isKindOfClass:[UIColorClass class]]) {
            
            CGFloat red, green, blue;
            [paramBackgroundColor getRed:&red green:&green blue:&blue alpha:NULL];
            
            [self setBackgroundColorWithRed:(NSUInteger)(red   * 255.0)
                                      Green:(NSUInteger)(green * 255.0)
                                       Blue:(NSUInteger)(blue  * 255.0)];
        } else {
#if !TARGET_OS_IPHONE
            NSColor *color = [paramBackgroundColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
            
            NSUInteger red, green, blue;
            
            red   = (NSUInteger)([color redComponent]   * 255.0);
            green = (NSUInteger)([color greenComponent] * 255.0);
            blue  = (NSUInteger)([color blueComponent]  * 255.0);
            
            [self setBackgroundColorWithRed:red Green:green Blue:blue];
#endif
        }
    }//if (paramBackgroundColor) {
}


#pragma mark Format

- (NSString *)logHeaderDescription {
    if (!_logHeaderDescription) {
        _logHeaderDescription = [self defaultStatusMessageForLogType:_logType
                                                               level:_logLevel];
    }
    return _logHeaderDescription;
}

- (void)setLogHeaderDescription:(NSString *)paramLogDescription {
    _logHeaderDescription = paramLogDescription;
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

#pragma mark Helpers
+ (NSString *)stringFromLogType:(XLOGGER_TYPE)paramLogType {
    
    switch (paramLogType) {
        case XLOGGER_TYPE_NSLOG_REPLACEMENT:
            return @"XLOGGER_TYPE_NSLOG_REPLACEMENT";
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

+ (NSString *)stringFromLogLevel:(XLOGGER_LEVEL)paramLogLevel {
    
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_SIMPLE:
            return @"_LEVEL_SIMPLE";
            break;
        case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
            return @"_LEVEL_SIMPLE_NO_HEADER";
            break;
        case XLOGGER_LEVEL_INFORMATION:
            return @"_LEVEL_INFORMATION";
            break;
        case XLOGGER_LEVEL_HIGHLIGHT:
            return @"_LEVEL_HIGHLIGHT";
            break;
        case XLOGGER_LEVEL_WARNING:
            return @"_LEVEL_WARNING";
            break;
        case XLOGGER_LEVEL_ERROR:
            return @"_LEVEL_ERROR";
            break;
        default:
            break;
    }
    return nil;
}


#pragma mark - PRIVATE

#pragma mark XLColorThemes Notifications
- (void)colorThemeDidChange {
    self.colorThemeDictionary = [self.colorThemesManager getColorThemeForType: _logType];
    self.outputColor = nil;
    self.textColorFormat = nil;
    self.backgroundColorFormat = nil;
    
}

#pragma mark Colors
- (void)loadDefaultColorThemeForLevel:(XLOGGER_LEVEL)paramLogLevel {
    
    static NSCharacterSet *decimalCharset;
    if (!decimalCharset) {
        decimalCharset = [NSCharacterSet decimalDigitCharacterSet];
    }
    
    static NSMutableCharacterSet *separatorCharset;
    if (!separatorCharset) {
        separatorCharset = [NSMutableCharacterSet characterSetWithCharactersInString:@",./-*+"];
        [separatorCharset formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if (self.colorThemeDictionary) {
        NSString *logLevel        = [self.colorThemesManager keyFromLogLevel:paramLogLevel];
        
        NSString *textColorString = self.colorThemeDictionary[logLevel][key_XLCOLORTHEMES_TEXT];
        NSString *bgndColorString = self.colorThemeDictionary[logLevel][key_XLCOLORTHEMES_BACKGROUND];
        
        if ([textColorString rangeOfCharacterFromSet:decimalCharset].location != NSNotFound) {
            
            NSArray *RGBValues = [textColorString componentsSeparatedByCharactersInSet:separatorCharset];
            
            NSUInteger red   = (NSUInteger)[RGBValues[0] integerValue];
            NSUInteger green = (NSUInteger)[RGBValues[1] integerValue];
            NSUInteger blue  = (NSUInteger)[RGBValues[2] integerValue];
            
            [self setTextColorWithRed:red Green:green Blue:blue];
        } else {
            XLColor *textColor = [self colorFromString:textColorString];
            [self setTextColor:textColor];
        }
        
        if ([bgndColorString rangeOfCharacterFromSet:decimalCharset].location != NSNotFound) {
            NSArray *RGBValues = [bgndColorString componentsSeparatedByCharactersInSet:separatorCharset];
            
            NSUInteger red   = (NSUInteger)[RGBValues[0] integerValue];
            NSUInteger green = (NSUInteger)[RGBValues[1] integerValue];
            NSUInteger blue  = (NSUInteger)[RGBValues[2] integerValue];
            
            [self setBackgroundColorWithRed:red Green:green Blue:blue];
        } else {
            XLColor *bgndColor = [self colorFromString:bgndColorString];
            [self setBackgroundColor:bgndColor];
        }
    }
}

- (XLColor *)colorFromString:(NSString *)paramColorString {
    
    SEL selector = NSSelectorFromString(paramColorString);
    
    if ([XLColor respondsToSelector:selector]) {
        return [XLColor performSelector:selector];
    }
    
    return nil;
}

- (NSString *)outputColorForLevel:(XLOGGER_LEVEL)paramLogLevel
{
    if (self.colorsEnabled) {
        
        if (!self.textColorFormat && !self.backgroundColorFormat) {
            [self loadDefaultColorThemeForLevel:paramLogLevel];
        }
        
        if (self.textColorFormat && self.backgroundColorFormat) {
            return [NSString stringWithFormat:@"%@%@%@%@",
                    XCODE_COLORS_ESCAPE,
                    self.textColorFormat,
                    XCODE_COLORS_ESCAPE,
                    self.backgroundColorFormat];
        } else if (self.textColorFormat) {
            return [NSString stringWithFormat:@"%@%@",XCODE_COLORS_ESCAPE,self.textColorFormat];
        } else if (self.backgroundColorFormat) {
            return [NSString stringWithFormat:@"%@%@",XCODE_COLORS_ESCAPE,self.backgroundColorFormat];
        }
        
    }
    
    return nil;
}


- (NSString *)convertBackgroundColorToText:(NSString *)colorString
{
    return [colorString stringByReplacingOccurrencesOfString:@"bg"
                                                  withString:[NSString stringWithFormat:@"%@fg",XCODE_COLORS_ESCAPE]];
}

#pragma mark Log Status
- (NSDictionary *)getDefaultStatusInformations {
    
    static NSDictionary *defaultStatusInformations;
    
    if (!defaultStatusInformations) {
        NSDictionary *logLevelsStatusColors;
        logLevelsStatusColors = @{XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                      DEFAULT_BGRD_COLOR_INFO_LEVEL,
                                  XLog_Key(XLOGGER_LEVEL_HIGHLIGHT)  :
                                      DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL,
                                  XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                      DEFAULT_STATUS_TEXT_COLOR_WARNING,
                                  XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                      DEFAULT_BGRD_COLOR_ERROR_LEVEL
                                  };
        
        NSDictionary *dLogLevelsStatusMessages;
        dLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                         STATUS_DLOG_SIMPLE,
                                     XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                         STATUS_DLOG_INFO,
                                     XLog_Key(XLOGGER_LEVEL_HIGHLIGHT)  :
                                         STATUS_DLOG_HIGHLIGHT,
                                     XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                         STATUS_DLOG_WARNING,
                                     XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                         STATUS_DLOG_ERROR
                                     };
        
        NSDictionary *dvLogLevelsStatusMessages;
        dvLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                          STATUS_DVLOG_SIMPLE,
                                      XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                          STATUS_DVLOG_INFO,
                                      XLog_Key(XLOGGER_LEVEL_HIGHLIGHT)  :
                                          STATUS_DVLOG_HIGHLIGHT,
                                      XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                          STATUS_DVLOG_WARNING,
                                      XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                          STATUS_DVLOG_ERROR
                                      };
        
        NSDictionary *ddLogLevelsStatusMessages;
        ddLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                          STATUS_DDLOG_SIMPLE,
                                      XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                          STATUS_DDLOG_INFO,
                                      XLog_Key(XLOGGER_LEVEL_HIGHLIGHT)  :
                                          STATUS_DDLOG_HIGHLIGHT,
                                      XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                          STATUS_DDLOG_WARNING,
                                      XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                          STATUS_DDLOG_ERROR
                                      };
        
        NSDictionary *oLogLevelsStatusMessages;
        oLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                         STATUS_OLOG_SIMPLE,
                                     XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                         STATUS_OLOG_INFO,
                                     XLog_Key(XLOGGER_LEVEL_HIGHLIGHT)  :
                                         STATUS_OLOG_HIGHLIGHT,
                                     XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                         STATUS_OLOG_WARNING,
                                     XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                         STATUS_OLOG_ERROR
                                     };
        
        defaultStatusInformations = @{key_Status_Color                        :
                                          logLevelsStatusColors,
                                      XLog_Key(XLOGGER_TYPE_DEBUG)            :
                                          dLogLevelsStatusMessages,
                                      XLog_Key(XLOGGER_TYPE_DEVELOPMENT)      :
                                          dvLogLevelsStatusMessages,
                                      XLog_Key(XLOGGER_TYPE_DEBUG_DEVELOPMENT):
                                          ddLogLevelsStatusMessages,
                                      XLog_Key(XLOGGER_TYPE_ONLINE_SERVICES)  :
                                          oLogLevelsStatusMessages};
    }
    
    return defaultStatusInformations;
}

- (NSString *)defaultStatusMessageForLogType:(XLOGGER_TYPE)paramLogType level:(XLOGGER_LEVEL)paramLogLevel
{
    
    NSDictionary *statusDictionary = [self getDefaultStatusInformations];
    NSString     *statusMessage = statusDictionary[XLog_Key(paramLogType)][XLog_Key(paramLogLevel)];
    
    if (self.colorsEnabled) {
        
        NSString *statusColor   = statusDictionary[key_Status_Color][XLog_Key(paramLogLevel)];
        switch (paramLogLevel) {
            case XLOGGER_LEVEL_SIMPLE:
                return statusMessage;
                break;
            default:
            {
                return [NSString stringWithFormat:@"%@%@%@",
                        [self convertBackgroundColorToText: statusColor],
                        statusMessage,
                        XCODE_COLORS_RESET];
            }
                break;
        }
    } else {
        return statusMessage;
    }
    return nil;
}

@end
