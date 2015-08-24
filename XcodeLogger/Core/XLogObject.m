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
#define key_RGB_Red   @"red"
#define key_RGB_Green @"green"
#define key_RGB_Blue  @"blue"

static NSString *const DEFAULT_HEADER_FORMAT             = @"(%@)=> [>%@<]:%@:[#%@]:[> %@ <]";
static NSString *const DEFAULT_HEADER_FORMAT_SCHEME_LOGS = @"[%@](%@)=> [>%@<]:%@:[#%@]:[> %@ <]";

@interface XLogObject ()
{
    XLOGGER_TYPE  _logType;
    XLOGGER_LEVEL _logLevel;
    NSUInteger _numberOfNewLinesAfterHeader;
    NSUInteger _numberOfNewLinesAfterOutput;
}

@property (nonatomic, strong) XLColorThemes *colorThemesManager;

@property (nonatomic, readwrite) NSString *logHeaderDescription;
@property (nonatomic, readwrite) NSString *logDescription;
@property (nonatomic, readwrite) NSString *buildScheme;
@property (nonatomic, readwrite) NSString *outputColor;
@property (nonatomic, readwrite) NSString *newlinesAfterHeader;
@property (nonatomic, readwrite) NSString *newlinesAfterOutput;

@property (nonatomic, copy) NSString *textColorFormat;
@property (nonatomic, copy) NSString *backgroundColorFormat;

@property (nonatomic, copy) NSString *logHeaderDescriptionMessageString;
@property (nonatomic, copy) NSString *logHeaderDescriptionColorFormat;

@property (nonatomic, copy) NSDictionary *colorThemeDictionary;

@property (nonatomic, assign) BOOL colorsEnabled;

@end

@implementation XLogObject


/* ------------------ */
#pragma mark - PUBLIC
/* ------------------ */


#pragma mark - Init
- (instancetype)init {
    [NSException raise:@"XLogObject Safe Initialization"
                format:@"Use -[initWithLogType:level:colorsEnabled:] instead of -[init]."];
    return nil;
}

- (instancetype)initWithLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                  colorsEnabled:(BOOL)paramColorsEnabled {
    
    if (self = [super init]) {
        
        _logType        = paramLogType;
        _logLevel       = paramLogLevel;
        _logDescription = [self stringFromLogType:_logType level:_logLevel];
        _colorsEnabled  = paramColorsEnabled;
        
        [self loadDefaults];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(colorThemeDidChange)
                                                     name:XL_THEME_DID_CHANGE_NOTIFICATION
                                                   object:_colorThemesManager];
    }
    return self;
}


#pragma mark Scheme Linking
- (void)setBuildScheme:(NSString *)buildScheme {
    _buildScheme = buildScheme;
}


#pragma mark Format
@synthesize logHeaderDescription = _logHeaderDescription;


- (NSString *)logHeaderDescription {
    //make sure the colors are fresh & loaded in case something changed
    if (!_logHeaderDescriptionColorFormat) {
        [self outputColor];
    }
    
    //load a default message if nothing is customized
    if (!_logHeaderDescription) {
        _logHeaderDescription = [self defaultLogDescriptionForLogType:_logType
                                                                level:_logLevel];
    } else {
        //colorize the custom description
        _logHeaderDescription = [self colorFormattedStringFromString:self.logHeaderDescriptionMessageString
                                                     withColorFormat:self.logHeaderDescriptionColorFormat];
    }
    
    
    return _logHeaderDescription;
}

- (void)setLogHeaderDescription:(NSString *)paramLogDescription {
    //store the non-colored version of the custom description
    _logHeaderDescriptionMessageString = paramLogDescription;
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


#pragma mark Colors
- (NSString *)outputColor {
    if (!_outputColor) {
        _outputColor = [self setColorsForLevel: _logLevel];
    }
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
        NSDictionary *RGBValues = [self RGBColorsFromXLColor:paramTextColor];
        [self setTextColorWithRed:[RGBValues[key_RGB_Red]   unsignedIntegerValue]
                            Green:[RGBValues[key_RGB_Green] unsignedIntegerValue]
                             Blue:[RGBValues[key_RGB_Blue]  unsignedIntegerValue]];
    }
    else {
        self.outputColor = nil;
        self.textColorFormat = nil;
    }
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
        
        NSDictionary *RGBValues = [self RGBColorsFromXLColor:paramBackgroundColor];
        [self setBackgroundColorWithRed:[RGBValues[key_RGB_Red]   unsignedIntegerValue]
                                  Green:[RGBValues[key_RGB_Green] unsignedIntegerValue]
                                   Blue:[RGBValues[key_RGB_Blue]  unsignedIntegerValue]];
    }
    else {
        self.outputColor = nil;
        self.backgroundColorFormat = nil;
    }
}

- (void)setColorForLogHeaderDescription:(XLColor *)paramColor {
    
    NSDictionary *RGBValues = [self RGBColorsFromXLColor:paramColor];
    if (RGBValues) {
        self.logHeaderDescriptionColorFormat = [NSString stringWithFormat:@"fg%tu,%tu,%tu;",
                                                [RGBValues[key_RGB_Red]   unsignedIntegerValue],
                                                [RGBValues[key_RGB_Green] unsignedIntegerValue],
                                                [RGBValues[key_RGB_Blue]  unsignedIntegerValue]];
    } else {
        self.logHeaderDescriptionColorFormat = nil;
    }
}

#pragma mark Informations
- (XLOGGER_TYPE)logType {
    return _logType;
}

- (XLOGGER_LEVEL)logLevel {
    return _logLevel;
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
        case XLOGGER_LEVEL_IMPORTANT:
            return @"_LEVEL_IMPORTANT";
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


/* ------------------ */
#pragma mark - PRIVATE
/* ------------------ */


#pragma mark Init
- (void)loadDefaults {
    _colorThemesManager   = [XLColorThemes sharedManager];
    _colorThemeDictionary = [_colorThemesManager getColorThemeForType: _logType];
    
    _newlinesAfterHeader = @"\n";
    _newlinesAfterOutput = @"\n\n";
    
    if (_logType == XLOGGER_TYPE_DEBUG_DEVELOPMENT) {
        _buildScheme = @"sharedScheme";
    }
    
    self.outputColor = [self setColorsForLevel:_logLevel];
    [self loadDefaultInformationHeader];
}

- (void)loadDefaultInformationHeader {
    if (_logType == XLOGGER_TYPE_NSLOG_REPLACEMENT) {
        if (_logLevel != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
            _headerFormat    = DEFAULT_HEADER_FORMAT;
            _headerArguments = @[XL_ARG_TIMESTAMP,
                                 XL_ARG_CALLEE_ADDRESS,
                                 XL_ARG_FILE_NAME,
                                 XL_ARG_LINE_NUMBER,
                                 XL_ARG_CALLEE_METHOD];
            
        }
    } else {
        if (_logLevel != XLOGGER_LEVEL_SIMPLE_NO_HEADER) {
            _headerFormat    = DEFAULT_HEADER_FORMAT_SCHEME_LOGS;
            _headerArguments = @[XL_ARG_LOG_DESCRIPTION,
                                 XL_ARG_TIMESTAMP,
                                 XL_ARG_CALLEE_ADDRESS,
                                 XL_ARG_FILE_NAME,
                                 XL_ARG_LINE_NUMBER,
                                 XL_ARG_CALLEE_METHOD];
        }
    }
    
}

#pragma mark XLColorThemes Notifications
- (void)colorThemeDidChange {
    self.colorThemeDictionary  = [self.colorThemesManager getColorThemeForType: _logType];
    self.outputColor           = nil;
    self.textColorFormat       = nil;
    self.backgroundColorFormat = nil;
 //   self.logHeaderDescriptionColorFormat = nil;
}

#pragma mark Colors
- (NSDictionary *)RGBColorsFromString:(NSString *)paramColorString {
    
    static NSCharacterSet *decimalCharset;
    if (!decimalCharset) {
        decimalCharset = [NSCharacterSet decimalDigitCharacterSet];
    }
    
    static NSMutableCharacterSet *separatorCharset;
    if (!separatorCharset) {
        separatorCharset = [NSMutableCharacterSet characterSetWithCharactersInString:@",./-*+"];
        [separatorCharset formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if ([paramColorString rangeOfCharacterFromSet:decimalCharset].location != NSNotFound) {
        NSArray *RGBValues = [paramColorString componentsSeparatedByCharactersInSet:separatorCharset];
        
        NSNumber *red   = [NSNumber numberWithUnsignedInteger:(NSUInteger)[RGBValues[0] integerValue]];
        NSNumber *green = [NSNumber numberWithUnsignedInteger:(NSUInteger)[RGBValues[1] integerValue]];
        NSNumber *blue  = [NSNumber numberWithUnsignedInteger:(NSUInteger)[RGBValues[2] integerValue]];
        
        NSDictionary *RGBColorsDictionary = @{key_RGB_Red:red,key_RGB_Green:green,key_RGB_Blue:blue};
        return RGBColorsDictionary;
    }
    return nil;
}

- (NSDictionary *)RGBColorsFromXLColor:(XLColor *)paramColor {
    
    NSDictionary *RGBDictionary;
    
    if (paramColor) {
        NSString *UIColorClassString = @"UIColor";
        Class UIColorClass = NSClassFromString(UIColorClassString);
        
        if ([paramColor isKindOfClass:[UIColorClass class]]) {
            
            CGFloat red, green, blue;
            [paramColor getRed:&red green:&green blue:&blue alpha:NULL];
            
            RGBDictionary = @{key_RGB_Red  :[NSNumber numberWithUnsignedInteger:(NSUInteger)(red   * 255.0)],
                              key_RGB_Green:[NSNumber numberWithUnsignedInteger:(NSUInteger)(green * 255.0)],
                              key_RGB_Blue :[NSNumber numberWithUnsignedInteger:(NSUInteger)(blue  * 255.0)]};
        } else {
#if !TARGET_OS_IPHONE
            NSColor *color = [paramColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
            
            NSUInteger red, green, blue;
            
            red   = (NSUInteger)([color redComponent]   * 255.0);
            green = (NSUInteger)([color greenComponent] * 255.0);
            blue  = (NSUInteger)([color blueComponent]  * 255.0);
            
            RGBDictionary = @{key_RGB_Red  :[NSNumber numberWithUnsignedInteger:red],
                              key_RGB_Green:[NSNumber numberWithUnsignedInteger:green],
                              key_RGB_Blue :[NSNumber numberWithUnsignedInteger:blue]};
#endif
        }
    }
    return RGBDictionary;
}

- (XLColor *)colorFromString:(NSString *)paramColorString {
    
    SEL selector = NSSelectorFromString(paramColorString);
    
    if ([XLColor respondsToSelector:selector]) {
        return [XLColor performSelector:selector];
    }
    
    return nil;
}

- (NSString *)convertBackgroundColorToText:(NSString *)colorString {
    return [colorString stringByReplacingOccurrencesOfString:@"bg"
                                                  withString:@"fg"];
}

- (void)loadColorThemeForLevel:(XLOGGER_LEVEL)paramLogLevel {
    
    if (self.colorThemeDictionary) {
        NSString *logLevel        = [self.colorThemesManager keyFromLogLevel:paramLogLevel];
        NSString *textColorString = self.colorThemeDictionary[logLevel][key_XLCOLORTHEMES_TEXT];
        NSString *bgndColorString = self.colorThemeDictionary[logLevel][key_XLCOLORTHEMES_BACKGROUND];
        
        NSDictionary *textColorDictionary = [self RGBColorsFromString:textColorString];
        NSDictionary *bgndColorDictionary = [self RGBColorsFromString:bgndColorString];
        
        if (textColorDictionary) {
            [self setTextColorWithRed:[textColorDictionary[key_RGB_Red]   unsignedIntegerValue]
                                Green:[textColorDictionary[key_RGB_Green] unsignedIntegerValue]
                                 Blue:[textColorDictionary[key_RGB_Blue]  unsignedIntegerValue]];
        } else {
            XLColor *textColor = [self colorFromString:textColorString];
            [self setTextColor:textColor];
        }
        
        if (bgndColorDictionary) {
            [self setBackgroundColorWithRed:[bgndColorDictionary[key_RGB_Red]   unsignedIntegerValue]
                                      Green:[bgndColorDictionary[key_RGB_Green] unsignedIntegerValue]
                                       Blue:[bgndColorDictionary[key_RGB_Blue]  unsignedIntegerValue]];
        } else {
            XLColor *bgndColor = [self colorFromString:bgndColorString];
            [self setBackgroundColor:bgndColor];
        }
    }
}

- (NSString *)setColorsForLevel:(XLOGGER_LEVEL)paramLogLevel
{
    if (self.colorsEnabled) {
        
        //if there are no colors loaded for both text and background
        if (!self.textColorFormat && !self.backgroundColorFormat) {
            //(re)load the color theme
            [self loadColorThemeForLevel:paramLogLevel];
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


#pragma mark Log Status
- (NSDictionary *)defaultLogDescriptionMessages {
    
    static NSDictionary *defaultStatusInformations;
    
    if (!defaultStatusInformations) {
        NSDictionary *dLogLevelsStatusMessages;
        dLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                         @"DEBUG",
                                     XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                         @"DEBUG:INFO",
                                     XLog_Key(XLOGGER_LEVEL_IMPORTANT)  :
                                         @"DEBUG:IMPORTANT",
                                     XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                         @"DEBUG:WARNING",
                                     XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                         @"DEBUG:ERROR"
                                     };
        
        NSDictionary *dvLogLevelsStatusMessages;
        dvLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                          @"DEVELOPMENT",
                                      XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                          @"DEVELOPMENT:INFO",
                                      XLog_Key(XLOGGER_LEVEL_IMPORTANT)  :
                                          @"DEVELOPMENT:IMPORTANT",
                                      XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                          @"DEVELOPMENT:WARNING",
                                      XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                          @"DEVELOPMENT:ERROR"
                                      };
        
        NSDictionary *ddLogLevelsStatusMessages;
        ddLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                          @"DBG&DEV",
                                      XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                          @"DBG&DEV:INFO",
                                      XLog_Key(XLOGGER_LEVEL_IMPORTANT)  :
                                          @"DBG&DEV:IMPORTANT",
                                      XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                          @"DBG&DEV:WARNING",
                                      XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                          @"DBG&DEV:ERROR"
                                      };
        
        NSDictionary *oLogLevelsStatusMessages;
        oLogLevelsStatusMessages = @{XLog_Key(XLOGGER_LEVEL_SIMPLE)     :
                                         @"ONLINE",
                                     XLog_Key(XLOGGER_LEVEL_INFORMATION):
                                         @"ONLINE:INFO",
                                     XLog_Key(XLOGGER_LEVEL_IMPORTANT)  :
                                         @"ONLINE:IMPORTANT",
                                     XLog_Key(XLOGGER_LEVEL_WARNING)    :
                                         @"ONLINE:WARNING",
                                     XLog_Key(XLOGGER_LEVEL_ERROR)      :
                                         @"ONLINE:ERROR"
                                     };
        
        defaultStatusInformations = @{XLog_Key(XLOGGER_TYPE_DEBUG)            :
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

- (NSString *)defaultLogDescriptionForLogType:(XLOGGER_TYPE)paramLogType
                                        level:(XLOGGER_LEVEL)paramLogLevel {
    
    NSDictionary *statusDictionary = [self defaultLogDescriptionMessages];
    NSString     *statusMessage    = statusDictionary[XLog_Key(paramLogType)][XLog_Key(paramLogLevel)];
    
    [self setLogHeaderDescriptionMessageString: statusMessage];
    statusMessage = [self colorFormattedStringFromString:statusMessage
                                         withColorFormat:nil];
    
    return statusMessage;
}

- (NSString *)colorFormattedStringFromString:(NSString *)paramString
                             withColorFormat:(NSString *)paramColorFormat {
    
    NSString *colorFormat;
    
    if (self.colorsEnabled) {
        
        if (paramColorFormat) {
            colorFormat = paramColorFormat;
        } else if (self.backgroundColorFormat) {
            colorFormat = [self convertBackgroundColorToText: self.backgroundColorFormat];
        } else {
            colorFormat = self.textColorFormat;
        }
        
        colorFormat = [NSString stringWithFormat:@"%@%@%@%@",
                       XCODE_COLORS_ESCAPE,
                       colorFormat,
                       paramString,
                       XCODE_COLORS_RESET];
        
        return colorFormat;
    }
    
    return paramString;
}

#pragma mark Helpers
- (NSString *)stringFromLogType:(XLOGGER_TYPE)logType
                          level:(XLOGGER_LEVEL)logLevel {
    return [[self.class stringFromLogType:logType]
            stringByAppendingString:
            [self.class stringFromLogLevel:logLevel]];
}


@end
