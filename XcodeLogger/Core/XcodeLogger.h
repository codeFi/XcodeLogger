//
//  XcodeLogger.h
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


#import <Foundation/Foundation.h>
#import "XLogTypes.h"


// THE DEFAULT COLOR THEMES FOR XCODE LOGGER
// YOU'RE INVITED TO ADD(CREATE) MORE HERE AND SEND A PULL REQUEST (check -[printColorThemeCreationInstructions])
static NSString *const XLCT_DEFAULT_LIGHT_THEME  = @"DEFAULT_LIGHT_THEME"; //based on Xcode's Default Theme
static NSString *const XLCT_DEFAULT_DUSK_THEME   = @"DEFAULT_DUSK_THEME";  //based on Xcode's Dusk Theme
static NSString *const XLCT_DEFAULT_DARK_THEME   = @"DEFAULT_DARK_THEME";  //based on Xcode's Midnight Theme
static NSString *const XLCT_SOLARIZE_LIGHT_THEME = @"SOLARIZE_LIGHT_THEME";//Based on Solarize Light Theme by Jason Brennan https://github.com/jbrennan/xcode4themes
static NSString *const XLCT_SOLARIZE_DARK_THEME  = @"SOLARIZE_DARK_THEME"; //Based on Solarize Dark Theme by Jason Brennan https://github.com/jbrennan/xcode4themes
static NSString *const XLCT_DRACULA_THEME        = @"DRACULA_THEME";       //Based on Dracula Theme by Zeno Rocha https://github.com/zenorocha/dracula-theme


@interface XcodeLogger : NSObject

#pragma mark - Initializer/Accessor
/*!
 *  @brief  Designated initializer and instance accessor for Xcode Logger.
 *
 *  @return The Xcode Logger singleton instance.
 */
+ (XcodeLogger *)sharedManager;


#pragma mark - Scheme Linking
/*!
 *  @brief  Sets the name of the key defined in your project's @c Info.plist file. Xcode Logger will use that entry to check the currently running scheme.
 *
 *  @param paramRunningSchemeKey The key as a string.
 */
- (void)setInfoPlistKeyNameForRunningSchemes:(NSString *)paramRunningSchemeKey;

/*!
 *  @brief  Links a @c build/running scheme with an <code>Xcode Logger Type</code>.
 *
 *  @param paramSchemeName The name of the scheme as a string (case-insensitive). The name you must provide is the one from the <code>Scheme Menu</code> in Xcode's @c Toolbar.
 *  @param paramLogType   An enumerated value of type @c XLOGGER_TYPE.
 *  @note XLOGGER_TYPE enums:
 *  @code
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 */
- (void)setBuildSchemeName:(NSString *)paramSchemeName
               forXLogType:(XLOGGER_TYPE)paramLogType;


#pragma mark - Filters

/*!
 * @brief Call this in any of your classes to filter per class, the output by the logger level(s) you want.
 * @discussion This method forces every logger type to output only the selected levels. This filter is <u>per class</u> so you can have a different filter for every class from which you call it.
 * @discussion You can also call this method multiple times in an initializer class of your app (like @c AppDelegate) and set the <i><u>file names</u></i> for which you want to set filters on. The file names are <u>case-insensitive</u>.
 * @note There's also a convenience <strong>macro</strong>: <code>XL_FILTER_LEVELS()</code> which provides the <i>current file name</i> of the @c Class from which you call this method so the only thing left to do is to add the <i>levels</i> you wish to filter.
 *
 * @code
 *
 * //Showing only Simple and Warning Outputs
 *
 * XL_FILTER_LEVELS( XL_LEVEL_SIMPLE, XL_LEVEL_WARNING )
 *
 * //As you can observe, there are some convenience
 * //macros for XLOGGER_LEVEL_### enums:
 *
 * XL_LEVEL_SIMPLE
 * XL_LEVEL_SIMPLE_NO_HEADER
 * XL_LEVEL_INFORMATION
 * XL_LEVEL_IMPORTANT
 * XL_LEVEL_WARNING
 * XL_LEVEL_ERROR
 *
 * @endcode
 *
 * @param paramLogLevels An array containing the levels you want to get output from. You can use the convenience macros provided.
 * @param paramFileName A string with the name of a class implementation file (.m). The file name must be suffixed by its extension (.m).
 */
- (void)filterXLogLevels:(NSArray *)paramLogLevels
             forFileName:(NSString *)paramFileName;

#define XL_FILTER_LEVELS(...) \
[[XcodeLogger sharedManager] filterXLogLevels:[NSArray arrayWithObjects:__VA_ARGS__, nil] \
forFileName:[[NSString stringWithUTF8String:FILE_NAME] lastPathComponent]]


#pragma mark - Format
/*!
 *  @brief  Disables the default header and sets a new, custom header for a selected Xcode Logger Type and Level.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *      XLOGGER_LEVEL_ALL
 *   };
 *
 *  @endcode
 *
 *  @note XL_ARG_### macros:
 *  @code
 *
 *     > XL_ARG_TIMESTAMP
 *     > XL_ARG_CALLEE_ADDRESS
 *     > XL_ARG_CALLEE_METHOD
 *     > XL_ARG_LINE_NUMBER
 *     > XL_ARG_FILE_NAME
 *
 *  @endcode
 *
 *  @param paramLogType     An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramLogLevel    An enumerated value of type @c XLOGGER_LEVEL. You can use @c XLOGGER_LEVEL_ALL enum value to set the same header for every level of the selected @c XLOGGER_TYPE.
 *  @param paramHeaderFormat A formatted string with placeholders for default arguments @c (XL_ARG_###) or custom arguments. <strong>Note:</strong> When using the @c XL_ARG_### macros, the placeholders must be of object type @c (%@).
 *  @param paramArguments    An @c array with arguments <u>exactly matching the number and order</u> of @c paramHeaderFormat placeholders.
 */
- (void)setHeaderForXLogType:(XLOGGER_TYPE)paramLogType
                       level:(XLOGGER_LEVEL)paramLogLevel
                      format:(NSString *)paramHeaderFormat
                   arguments:(NSArray *)paramArguments;


/*!
 *  @brief Changes the default and sets a short (or long..) description string for each log type and level
 *  @discussion This method sets a string for the @c XL_ARG_LOG_DESCRIPTION argument which you can pass to
 *  <code><i>setHeaderForXLogType:level:format:arguments:</i></code> method.
 *
 *  @param paramLogDescription The description string.
 *  @param paramLogType An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramLogLevel    An enumerated value of type @c XLOGGER_LEVEL. NOTE: you <strong>cannot</strong> use @c XLOGGER_LEVEL_ALL enum value to set the same header for every level of the selected @c XLOGGER_TYPE.
 */
- (void)setLogHeaderDescription:(NSString *)paramLogDescription
                     forLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel __attribute((deprecated("Deprecated in version 1.2.0. Use setLogHeaderDescription:forLogType:level:color: instead.")));


/*!
 *  @brief Changes the default and sets a short (or long..) description string for each log type and level
 *  @discussion This method sets a string for the @c XL_ARG_LOG_DESCRIPTION argument which you can pass to
 *  <code><i>setHeaderForXLogType:level:format:arguments:</i></code> method.
 *  @discussion In case there's no @c XLColor passed as a parameter, this property takes its color
 * from either background or text colors of the output.
 *
 * It tries to get the color from the background color property first and if that's nil,
 * it will take it from the text color property.
 *
 * In case you specify an @c XLColor, the color of the Log Description <u>will not be changed</u>
 * if you load a different color theme later.
 *
 *  @param paramLogDescription The description string.
 *  @param paramLogType An enumerated value of type @c XLOGGER_TYPE. You can use @c XLOGGER_TYPE_ALL to set the same Log Description Header for every Log Type for the given Log Level.
 *  @param paramLogLevel An enumerated value of type @c XLOGGER_LEVEL. NOTE: you <strong>cannot</strong> use @c XLOGGER_LEVEL_ALL enum value to set the same header for every level of the selected @c XLOGGER_TYPE.
 *  @param paramColor An @c XLColor (UIColor or NSColor depending on the platform).
 */
- (void)setLogHeaderDescription:(NSString *)paramLogDescription
                     forLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                          color:(XLColor *)paramColor;


/*!
 *  @brief  Adds or removes new lines between the information header and the body of the output.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *      XLOGGER_LEVEL_ALL
 *   };
 *
 *  @endcode
 *
 *  @param paramNumberOfLines The number of new lines between the header and the body of the output.
 *  @param paramLogType      An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramLogLevel     An enumerated value of type @c XLOGGER_LEVEL. You can use @c XLOGGER_LEVEL_ALL enum value to set the same number of new lines for every level of the selected @c XLOGGER_TYPE.
 */
- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramLogType
                                 level:(XLOGGER_LEVEL)paramLogLevel;

/*!
 *  @brief  Adds or removes new lines between the body of the output and the header of the next log statement.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *      XLOGGER_LEVEL_ALL
 *   };
 *
 *  @endcode
 *
 *  @param paramNumberOfLines The number of new lines between the body of the output and the header of the next log statement.
 *  @param paramLogType      An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramLogLevel     An enumerated value of type @c XLOGGER_LEVEL. You can use @c XLOGGER_LEVEL_ALL enum value to set the same number of new lines for every level of the selected @c XLOGGER_TYPE.
 */
- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramLogType
                                 level:(XLOGGER_LEVEL)paramLogLevel;

/*!
 *  @brief  Changes the default timestamp format @c (HH:mm:ss).
 *
 *  @param paramTimestampFormat Pass a string containing a valid @c NSDateFormatter format.
 */
- (void)setTimestampFormat:(NSString *)paramTimestampFormat;


#pragma mark - Colors
/*!
 *  @brief  Enables or disables support for Xcode Colors plugin.
 *
 *  @note By default, colors are enabled (YES).
 *
 *  @param paramEnableColors Pass @c YES or @c NO.
 */
- (void)setColorLogsEnabled:(BOOL)paramEnableColors;

/*!
 *  @brief  Sets a text color for the output body (information header is excluded) from @c RGB values.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *   };
 *
 *  @endcode
 *
 *  @param paramLogType  An enumerated value of type @c XLOGGER_TYPE. You can use @c XLOGGER_TYPE_ALL to set the color for a given level for all log types.
 *  @param paramLogLevel An enumerated value of type @c XLOGGER_LEVEL. <strong>Warning:</strong> you aren't allowed to use @c XLOGGER_LEVEL_ALL enum value! Doing so will raise an exception.
 *  @param red            Integer value of a red level.
 *  @param green          Integer value of a green level.
 *  @param blue           Integer value of a blue level.
 */
- (void)setTextColorForXLogType:(XLOGGER_TYPE)paramLogType
                          level:(XLOGGER_LEVEL)paramLogLevel
                        withRed:(NSUInteger)red
                          Green:(NSUInteger)green
                           Blue:(NSUInteger)blue;

/*!
 *  @brief  Sets a text color for the output body (information header is excluded) from @c NSColor or @c UIColor (should use the XLColor macro).
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *   };
 *
 *  @endcode
 *
 *  @param paramTextColor An XLColor (NSColor or UIColor).
 *  @param paramLogType  An enumerated value of type @c XLOGGER_TYPE. You can use @c XLOGGER_TYPE_ALL to set the color for a given level for all log types.
 *  @param paramLogLevel An enumerated value of type @c XLOGGER_LEVEL. <strong>Warning:</strong> you aren't allowed to use @c XLOGGER_LEVEL_ALL enum value! Doing so will raise an exception.
 *
 */
- (void)setTextColor:(XLColor *)paramTextColor
         forXLogType:(XLOGGER_TYPE)paramLogType
               level:(XLOGGER_LEVEL)paramLogLevel;

/*!
 *  @brief  Sets a background color for the output body (information header is excluded) from @c RGB values.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *   };
 *
 *  @endcode
 *
 *  @param paramLogType  An enumerated value of type @c XLOGGER_TYPE. You can use @c XLOGGER_TYPE_ALL to set the color for a given level for all log types.
 *  @param paramLogLevel An enumerated value of type @c XLOGGER_LEVEL. <strong>Warning:</strong> you aren't allowed to use @c XLOGGER_LEVEL_ALL enum value! Doing so will raise an exception.
 *  @param red            Integer value of a red level.
 *  @param green          Integer value of a green level.
 *  @param blue           Integer value of a blue level.
 */
- (void)setBackgroundColorForXLogType:(XLOGGER_TYPE)paramLogType
                                level:(XLOGGER_LEVEL)paramLogLevel
                              withRed:(NSUInteger)red
                                Green:(NSUInteger)green
                                 Blue:(NSUInteger)blue;

/*!
 *  @brief  Sets a background color for the output body (information header is excluded) from @c NSColor or @c UIColor (should use the XLColor macro).
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG_REPLACEMENT,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 *
 *  @note XLOGGER_LEVEL enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
 *      XLOGGER_LEVEL_SIMPLE,
 *      XLOGGER_LEVEL_SIMPLE_NO_HEADER,
 *      XLOGGER_LEVEL_INFORMATION,
 *      XLOGGER_LEVEL_IMPORTANT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *   };
 *
 *  @endcode
 *
 *  @param paramBackgroundColor An XLColor (NSColor or UIColor).
 *  @param paramLogType  An enumerated value of type @c XLOGGER_TYPE. You can use @c XLOGGER_TYPE_ALL to set the color for a given level for all log types.
 *  @param paramLogLevel An enumerated value of type @c XLOGGER_LEVEL. <strong>Warning:</strong> you aren't allowed to use @c XLOGGER_LEVEL_ALL enum value! Doing so will raise an exception.
 */
- (void)setBackgroundColor:(XLColor *)paramBackgroundColor
               forXLogType:(XLOGGER_TYPE)paramLogType
                     level:(XLOGGER_LEVEL)paramLogLevel;

#pragma mark Color Themes

/*!
 *  @brief Returns the available color themes for Xcode Logger
 *  @discussion The themes are defined and created in XLColorThemes.plist file.
 */
- (NSArray *)availableColorThemes;

/*!
 *  @brief Loads a color theme XLColorThemes.plist file
 *  @discussion You can call this method multiple times in your classes if you want different color themes per class.
 *
 *  @param paramColorThemeName A string with the name of a color theme (case-insensitive). You can either use the constants starting with <strong>XLCT_</strong> for the default themes or call <code>(NSArray *)availableColorThemes</code> method to check what's new.
 */
- (void)loadColorThemeWithName:(NSString *)paramColorThemeName;

/*!
 *  @brief Prints to console the available Color Themes for Xcode Logger
 */
- (void)printAvailableColorThemes;

/*!
 *  @brief Prints to console a HOW-TO create new Color Themes for Xcode Logger
 *  @discussion If you want to share your theme with me and the community that uses Xcode Logger, you're invited to send a pull request: https://github.com/codeFi/XcodeLogger/pulls
 */
- (void)printColorThemeCreationInstructions;

@end



















#pragma mark - OUTPUT
/*!
 *  @warning DON'T CALL THIS FUNCTION! It's used only by Xcode Logger's macros.
 */
void  func_XLog_Output(XLOGGER_TYPE paramLogType,
                       XLOGGER_LEVEL paramLogLevel,
                       id callee,
                       const char *calleeMethod,
                       const char *fileName,
                       int lineNumber,
                       NSString *inputBody, ...);


#pragma mark - XLog Macros
#define XLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_NSLOG_REPLACEMENT,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_NSLOG_REPLACEMENT,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,FILE_NAME,0,input, ##__VA_ARGS__)
#define XLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_NSLOG_REPLACEMENT,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_IMPORTANT(input, ...) func_XLog_Output(XLOGGER_TYPE_NSLOG_REPLACEMENT,XLOGGER_LEVEL_IMPORTANT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_NSLOG_REPLACEMENT,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_NSLOG_REPLACEMENT,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - DLog Macros
#define DLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,FILE_NAME,0,input, ##__VA_ARGS__)
#define DLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_IMPORTANT(input, ...) func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_IMPORTANT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - DVLog Macros
#define DVLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,FILE_NAME,0,input, ##__VA_ARGS__)
#define DVLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_IMPORTANT(input, ...) func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_IMPORTANT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - DDLog Macros
#define DDLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,FILE_NAME,0,input, ##__VA_ARGS__)
#define DDLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_IMPORTANT(input, ...) func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_IMPORTANT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - OLog Macros
#define OLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,FILE_NAME,0,input, ##__VA_ARGS__)
#define OLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_IMPORTANT(input, ...) func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_IMPORTANT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - Header Parameters
#define CALLEE self
#define CALLEE_METHOD __PRETTY_FUNCTION__
#define FILE_NAME __FILE__
#define LINE_NUMBER __LINE__

