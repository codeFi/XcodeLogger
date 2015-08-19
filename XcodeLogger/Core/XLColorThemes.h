//
//  XLColorThemes.h
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


#import <Foundation/Foundation.h>
#import "XLogTypes.h"

extern NSString *const XL_THEME_DID_CHANGE_NOTIFICATION;

static NSString *const key_XLCOLORTHEMES_TEXT       = @"TXT_COLOR";
static NSString *const key_XLCOLORTHEMES_BACKGROUND = @"BGD_COLOR";


@interface XLColorThemes : NSObject

@property (strong, nonatomic, readonly) NSDictionary *currentThemeDictionary;

+ (XLColorThemes *)sharedManager;

- (void)loadColorThemeWithName:(NSString *)colorThemeName;
- (NSDictionary *)getColorThemeForType:(XLOGGER_TYPE)paramLogType;

- (NSString *)keyFromLogType:(XLOGGER_TYPE)paramLogType;
- (NSString *)keyFromLogLevel:(XLOGGER_LEVEL)paramLogLevel;

- (NSArray *)availableColorThemes;
- (NSString* )themeCreationInstructions;

@end

@interface NSDictionary (XLDictionary)
- (id)objectForCIKey:(NSString *)paramKey;
@end
@interface NSArray (XLArray)
- (BOOL)containsCIString:(NSString *)paramString;
@end