//
//  XcodeLogger.h
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 02/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLogTypes.h"

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
 *  @param paramXLogType   An enumerated value of type @c XLOGGER_TYPE.
 *  @note XLOGGER_TYPE enums:
 *  @code
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG,
 *      XLOGGER_TYPE_DEBUG,
 *      XLOGGER_TYPE_DEVELOPMENT,
 *      XLOGGER_TYPE_DEBUG_DEVELOPMENT,
 *      XLOGGER_TYPE_ONLINE_SERVICES
 *   };
 *
 *  @endcode
 */
- (void)setBuildSchemeName:(NSString *)paramSchemeName
               forXLogType:(XLOGGER_TYPE)paramXLogType;

#pragma mark - Format
/*!
 *  @brief  Disables the default header and sets a new, custom header for a selected Xcode Logger Type and Level.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG,
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
 *      XLOGGER_LEVEL_HIGHLIGHT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *      XLOGGER_ALL_LEVELS
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
 *  @param paramXLogType     An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramXLogLevel    An enumerated value of type @c XLOGGER_LEVEL. You can use @c XLOGGER_ALL_LEVELS enum value to set the same header for every level of the selected @c XLOGGER_TYPE.
 *  @param paramHeaderFormat A formatted string with placeholders for default arguments @c (XL_ARG_###) or custom arguments. <strong>Note:</strong> When using the @c XL_ARG_### macros, the placeholders must be of object type @c (%@).
 *  @param paramArguments    An @c array with arguments <u>exactly matching the number and order</u> of @c paramHeaderFormat placeholders.
 */
- (void)setHeaderForXLogType:(XLOGGER_TYPE)paramXLogType
                       level:(XLOGGER_LEVEL)paramXLogLevel
                      format:(NSString *)paramHeaderFormat
                   arguments:(NSArray *)paramArguments;

/*!
 *  @brief  Adds or removes new lines between the information header and the body of the output.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG,
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
 *      XLOGGER_LEVEL_HIGHLIGHT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *      XLOGGER_ALL_LEVELS
 *   };
 *
 *  @endcode
 *
 *  @param paramNumberOfLines The number of new lines between the header and the body of the output.
 *  @param paramXLogType      An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramXLogLevel     An enumerated value of type @c XLOGGER_LEVEL. You can use @c XLOGGER_ALL_LEVELS enum value to set the same number of new lines for every level of the selected @c XLOGGER_TYPE.
 */
- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramXLogType
                                 level:(XLOGGER_LEVEL)paramXLogLevel;

/*!
 *  @brief  Adds or removes new lines between the body of the output and the header of the next log statement.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG,
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
 *      XLOGGER_LEVEL_HIGHLIGHT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *      XLOGGER_ALL_LEVELS
 *   };
 *
 *  @endcode
 *
 *  @param paramNumberOfLines The number of new lines between the body of the output and the header of the next log statement.
 *  @param paramXLogType      An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramXLogLevel     An enumerated value of type @c XLOGGER_LEVEL. You can use @c XLOGGER_ALL_LEVELS enum value to set the same number of new lines for every level of the selected @c XLOGGER_TYPE.
 */
- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramXLogType
                                 level:(XLOGGER_LEVEL)paramXLogLevel;

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
 *      XLOGGER_TYPE_NSLOG,
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
 *      XLOGGER_LEVEL_HIGHLIGHT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *   };
 *
 *  @endcode
 *
 *  @param paramXLogType  An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramXLogLevel An enumerated value of type @c XLOGGER_LEVEL. <strong>Warning:</strong> you aren't allowed to use @c XLOGGER_ALL_LEVELS enum value! Doing so will raise an exception.
 *  @param red            Integer value of a red level.
 *  @param green          Integer value of a green level.
 *  @param blue           Integer value of a blue level.
 */
- (void)setTextColorForXLogType:(XLOGGER_TYPE)paramXLogType
                          level:(XLOGGER_LEVEL)paramXLogLevel
                        withRed:(NSUInteger)red
                          Green:(NSUInteger)green
                           Blue:(NSUInteger)blue;

/*!
 *  @brief  Sets a background color for the output body (information header is excluded) from @c RGB values.
 *
 *  @note XLOGGER_TYPE enums:
 *  @code
 *
 *  typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
 *      XLOGGER_TYPE_NSLOG,
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
 *      XLOGGER_LEVEL_HIGHLIGHT,
 *      XLOGGER_LEVEL_WARNING,
 *      XLOGGER_LEVEL_ERROR,
 *   };
 *
 *  @endcode
 *
 *  @param paramXLogType  An enumerated value of type @c XLOGGER_TYPE.
 *  @param paramXLogLevel An enumerated value of type @c XLOGGER_LEVEL. <strong>Warning:</strong> you aren't allowed to use @c XLOGGER_ALL_LEVELS enum value! Doing so will raise an exception.
 *  @param red            Integer value of a red level.
 *  @param green          Integer value of a green level.
 *  @param blue           Integer value of a blue level.
 */
- (void)setBackgroundColorForXLogType:(XLOGGER_TYPE)paramXLogType
                                level:(XLOGGER_LEVEL)paramXLogLevel
                              withRed:(NSUInteger)red
                                Green:(NSUInteger)green
                                 Blue:(NSUInteger)blue;

@end



















#pragma mark - OUTPUT
/*!
 *  @warning DON'T CALL THIS FUNCTION! It's used only by Xcode Logger's macros.
 */
void  func_XLog_Output(XLOGGER_TYPE paramXLogType,
                       XLOGGER_LEVEL paramXLogLevel,
                       id callee,
                       const char *calleeMethod,
                       const char *fileName,
                       int lineNumber,
                       NSString *inputBody, ...);


#pragma mark - XLog Macros
#define XLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_NSLOG,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_NSLOG,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,nil,0,input, ##__VA_ARGS__)
#define XLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_NSLOG,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_HIGHLIGHT(input, ...) func_XLog_Output(XLOGGER_TYPE_NSLOG,XLOGGER_LEVEL_HIGHLIGHT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_NSLOG,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define XLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_NSLOG,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - DLog Macros
#define DLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,nil,0,input, ##__VA_ARGS__)
#define DLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_HIGHLIGHT(input, ...) func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_HIGHLIGHT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_DEBUG,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - DVLog Macros
#define DVLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,nil,0,input, ##__VA_ARGS__)
#define DVLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_HIGHLIGHT(input, ...) func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_HIGHLIGHT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DVLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_DEVELOPMENT,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - DDLog Macros
#define DDLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,nil,0,input, ##__VA_ARGS__)
#define DDLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_HIGHLIGHT(input, ...) func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_HIGHLIGHT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define DDLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_DEBUG_DEVELOPMENT,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - OLog Macros
#define OLog(input, ...)           func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_SIMPLE,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_NH(input, ...)        func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_SIMPLE_NO_HEADER,nil,nil,nil,0,input, ##__VA_ARGS__)
#define OLog_INFO(input, ...)      func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_INFORMATION,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_HIGHLIGHT(input, ...) func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_HIGHLIGHT,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_WARNING(input, ...)   func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_WARNING,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)
#define OLog_ERROR(input, ...)     func_XLog_Output(XLOGGER_TYPE_ONLINE_SERVICES,XLOGGER_LEVEL_ERROR,CALLEE,CALLEE_METHOD,FILE_NAME,LINE_NUMBER,input, ##__VA_ARGS__)

#pragma mark - Header Parameters
#define CALLEE self
#define CALLEE_METHOD __PRETTY_FUNCTION__
#define FILE_NAME __FILE__
#define LINE_NUMBER __LINE__

