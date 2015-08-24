//
//  XLColorThemes.m
//  XcodeLogger-iOS-Sample
//
/*
 *  Created by Razvan Alin Tanase on 17/08/15. https://twitter.com/razvan_tanase
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


#import "XLColorThemes.h"

NSString *const XL_THEME_DID_CHANGE_NOTIFICATION = @"XcodeLoggerThemeDidChangeNotification";

static NSString *const XL_COLOR_THEMES_PLIST_NAME = @"XLColorThemes";

static NSString *const key_XLCOLORTHEMES_TYPE_ALL   = @"ALL";
static NSString *const key_XLCOLORTHEMES_TYPE_XLOG  = @"XLOG";
static NSString *const key_XLCOLORTHEMES_TYPE_DLOG  = @"DLOG";
static NSString *const key_XLCOLORTHEMES_TYPE_DVLOG = @"DVLOG";
static NSString *const key_XLCOLORTHEMES_TYPE_DDLOG = @"DDLOG";
static NSString *const key_XLCOLORTHEMES_TYPE_OLOG  = @"OLOG";

static NSString *const key_XLCOLORTHEMES_LEVELS_SIMPLE    = @"SIMPLE";
static NSString *const key_XLCOLORTHEMES_LEVELS_NOHEADER  = @"NO_HEADER";
static NSString *const key_XLCOLORTHEMES_LEVELS_INFO      = @"INFO";
static NSString *const key_XLCOLORTHEMES_LEVELS_IMPORTANT = @"IMPORTANT";
static NSString *const key_XLCOLORTHEMES_LEVELS_WARNING   = @"WARNING";
static NSString *const key_XLCOLORTHEMES_LEVELS_ERROR     = @"ERROR";

@interface XLColorThemes  ()
{
    NSMutableDictionary * _currentThemeDictionary;
}

@property (strong, nonatomic) NSDictionary *colorThemesDictionary;

@end

@implementation XLColorThemes

@synthesize currentThemeDictionary = _currentThemeDictionary;

#pragma mark - PUBLIC

- (void)loadColorThemeWithName:(NSString *)colorThemeName {
    
    if (colorThemeName) {
        
        if (!_currentThemeDictionary) {
            _currentThemeDictionary = [[NSMutableDictionary alloc] init];
        }
        
        if (self.colorThemesDictionary && [[self.colorThemesDictionary allKeys] count] > 0) {
            
            if (![self.colorThemesDictionary objectForCIKey:colorThemeName]) {
                
                NSLog(@"\n\n!!! {%@} THEME DOESN'T EXIST IN XCODE LOGGER'S COLOR THEMES PLIST! CHECK THE SPELLING. !!!\n\nAVAILABLE THEMES:\n%@\n\n",colorThemeName,[_colorThemesDictionary allKeys]);
                
                return;
            }
            
            [_currentThemeDictionary removeAllObjects];
            [_currentThemeDictionary addEntriesFromDictionary:[_colorThemesDictionary objectForCIKey:colorThemeName]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:XL_THEME_DID_CHANGE_NOTIFICATION
                                                                object:self];
            
        } else {
            NSLog(@"\n\n!!! THERE'S AN ISSUE WITH XCODE LOGGER'S COLOR THEMES PLIST! CHECK IF EXISTS IN YOUR PROJECT OR IF THERE ARE THEMES IN IT. !!!\n\n");
        }
    }
}

- (NSDictionary *)getColorThemeForType:(XLOGGER_TYPE)paramLogType {
    
    if (_currentThemeDictionary) {
        //if the current theme is for "ALL" Log Types
        if ([[_currentThemeDictionary allKeys] containsCIString:key_XLCOLORTHEMES_TYPE_ALL]) {
            
            id logLevels = [_currentThemeDictionary objectForCIKey:key_XLCOLORTHEMES_TYPE_ALL];
            
            if ([logLevels isKindOfClass:[NSDictionary class]]) {
                return logLevels;
            } else {
                NSLog(@"\n\n!!! CHECK YOUR XL THEME! THERE SHOULD BE A DICTIONARY NAMED \"LEVELS\" BUT IS NOT. !!!\n\n");
            }
            
        } else {
            
            NSString *logTypeKey = [self keyFromLogType:paramLogType];
            id logLevels = [_currentThemeDictionary objectForCIKey:logTypeKey];
            
            if ([logLevels isKindOfClass:[NSDictionary class]]) {
                return logLevels;
            } else {
                NSLog(@"\n\n!!! CHECK YOUR XL THEME! THERE SHOULD BE A DICTIONARY NAMED \"LEVELS\" BUT IS NOT. !!!\n\n");
            }
        }
    }
    return nil;
}

- (XLOGGER_TYPE)logTypeFromKey:(NSString *)paramKey {
    NSString *key = paramKey.uppercaseString;
    
    if ([key isEqualToString:key_XLCOLORTHEMES_TYPE_ALL]) {
        return XLOGGER_TYPE_ALL;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_TYPE_XLOG]) {
        return XLOGGER_TYPE_NSLOG_REPLACEMENT;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_TYPE_DLOG]) {
        return XLOGGER_TYPE_DEBUG;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_TYPE_DVLOG]) {
        return XLOGGER_TYPE_DEVELOPMENT;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_TYPE_DDLOG]) {
        return XLOGGER_TYPE_DEBUG_DEVELOPMENT;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_TYPE_OLOG]) {
        return XLOGGER_TYPE_ONLINE_SERVICES;
    }
    
    return 404;
}

- (NSString *)keyFromLogType:(XLOGGER_TYPE)paramLogType {
    switch (paramLogType) {
        case XLOGGER_TYPE_NSLOG_REPLACEMENT:
            return key_XLCOLORTHEMES_TYPE_XLOG;
            break;
        case XLOGGER_TYPE_DEBUG:
            return key_XLCOLORTHEMES_TYPE_DLOG;
            break;
        case XLOGGER_TYPE_DEVELOPMENT:
            return key_XLCOLORTHEMES_TYPE_DVLOG;
            break;
        case XLOGGER_TYPE_DEBUG_DEVELOPMENT:
            return key_XLCOLORTHEMES_TYPE_DDLOG;
            break;
        case XLOGGER_TYPE_ONLINE_SERVICES:
            return key_XLCOLORTHEMES_TYPE_OLOG;
            break;
        default:
            break;
    }
    return nil;
}

- (NSArray *)logTypesKeysArray {
    NSArray *logTypesArray = @[key_XLCOLORTHEMES_TYPE_ALL,
                               key_XLCOLORTHEMES_TYPE_XLOG,
                               key_XLCOLORTHEMES_TYPE_DLOG,
                               key_XLCOLORTHEMES_TYPE_DVLOG,
                               key_XLCOLORTHEMES_TYPE_DDLOG,
                               key_XLCOLORTHEMES_TYPE_OLOG];
    return logTypesArray;
}

- (XLOGGER_LEVEL)logLevelFromKey:(NSString *)paramKey {
    NSString *key = paramKey.uppercaseString;
    
    if ([key isEqualToString:key_XLCOLORTHEMES_LEVELS_SIMPLE]) {
        return XLOGGER_LEVEL_SIMPLE;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_LEVELS_NOHEADER]) {
        return XLOGGER_LEVEL_SIMPLE_NO_HEADER;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_LEVELS_INFO]) {
        return XLOGGER_LEVEL_INFORMATION;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_LEVELS_IMPORTANT]) {
        return XLOGGER_LEVEL_IMPORTANT;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_LEVELS_WARNING]) {
        return XLOGGER_LEVEL_WARNING;
    } else if ([key isEqualToString:key_XLCOLORTHEMES_LEVELS_ERROR]) {
        return XLOGGER_LEVEL_ERROR;
    }
    
    return 404;
}

- (NSString *)keyFromLogLevel:(XLOGGER_LEVEL)paramLogLevel {
    switch (paramLogLevel) {
        case XLOGGER_LEVEL_SIMPLE:
            return key_XLCOLORTHEMES_LEVELS_SIMPLE;
            break;
        case XLOGGER_LEVEL_SIMPLE_NO_HEADER:
            return key_XLCOLORTHEMES_LEVELS_NOHEADER;
            break;
        case XLOGGER_LEVEL_INFORMATION:
            return key_XLCOLORTHEMES_LEVELS_INFO;
            break;
        case XLOGGER_LEVEL_IMPORTANT:
            return key_XLCOLORTHEMES_LEVELS_IMPORTANT;
            break;
        case XLOGGER_LEVEL_WARNING:
            return key_XLCOLORTHEMES_LEVELS_WARNING;
            break;
        case XLOGGER_LEVEL_ERROR:
            return key_XLCOLORTHEMES_LEVELS_ERROR;
            break;
        default:
            break;
    }
    
    return nil;
}

- (NSArray *)availableColorThemes {
    return [[self colorThemesDictionary] allKeys];
}

- (NSString *)themeCreationInstructions {
    NSString *instructions = [NSString stringWithFormat:@"\n\nYOU CAN CREATE A NEW COLOR THEME FOR XCODE LOGGER BY FOLLOWING THESE STEPS:\n\nQUICK TIP: Duplicate one of the SAMPLE THEMES in XLColorThemes.plist with copy-paste and modify it.\n\n        If you want to read how it works keep parsing through these instructions.\n\nIMPORTANT: For each color string add the color value either as an NSColor or UIColor preset color components methods (ex: redColor) or\n           as RGB values with integer values separated by a comma, dot or whitespace (ex: 255,35,0).\n           If you go with UIColor/NSColor preset color components be sure to spell them correctly as they're case-sensitive.\n\nSTEP 1: In XLColorThemes.plist create a NEW DICTIONARY and set its key as your THEME's name.\n\nSTEP 2: Under your THEME DICTIONARY, create a NEW DICTIONARY depicting the Logger Type you wish to theme.\n        If your theme is the same for All Logger Types use the \"ALL\" key. These are the keys you can use:\n%@\n\nSTEP 3: Under your LOG TYPE DICTIONARY, create a NEW DICTIONARY for EACH LOG LEVEL.\n        These are the keys you can use:\n%@\n\nSTEP 4: Under each LOG LEVEL DICTIONARY, add two strings: one for text color and one for background color by using these keys:\n(\n    %@\n    %@\n)\n\n",[self logTypesKeysArray],[self logLevelsKeysArray],key_XLCOLORTHEMES_TEXT,key_XLCOLORTHEMES_BACKGROUND];
    
    return instructions;
}

- (NSArray *)logLevelsKeysArray {
    NSArray *logLevelsArray = @[key_XLCOLORTHEMES_LEVELS_SIMPLE,
                                key_XLCOLORTHEMES_LEVELS_NOHEADER,
                                key_XLCOLORTHEMES_LEVELS_INFO,
                                key_XLCOLORTHEMES_LEVELS_IMPORTANT,
                                key_XLCOLORTHEMES_LEVELS_WARNING,
                                key_XLCOLORTHEMES_LEVELS_ERROR];
    return logLevelsArray;
}

#pragma mark - PRIVATE

#pragma mark   Lazy init
- (NSDictionary *)colorThemesDictionary {
    if (!_colorThemesDictionary) {
        NSString *file = [[NSBundle mainBundle] pathForResource:XL_COLOR_THEMES_PLIST_NAME ofType:@"plist"];
        _colorThemesDictionary = [NSDictionary dictionaryWithContentsOfFile:file];
    }
    return _colorThemesDictionary;
}

#pragma mark - Singleton Specific
static XLColorThemes *_sharedInstance = nil;
static bool isFirstAccess = YES;

+ (XLColorThemes *)sharedManager {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
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
    return [[XLColorThemes alloc] init];
}

- (id)mutableCopy
{
    return [[XLColorThemes alloc] init];
}


@end

@implementation NSDictionary (XLDictionary)
- (id)objectForCIKey:(NSString *)paramKey {
    
    for (NSString *key in [self allKeys]) {
        if ([key localizedCaseInsensitiveCompare:paramKey] == NSOrderedSame) {
            return [self objectForKey:key];
        }
    }
    
    return nil;
}
@end
@implementation NSArray (XLArray)
- (BOOL)containsCIString:(NSString *)paramString {
    
    for (NSString *string in self) {
        if ([string localizedCaseInsensitiveCompare:paramString] == NSOrderedSame) {
            return YES;
        }
    }
    
    return NO;
}
@end