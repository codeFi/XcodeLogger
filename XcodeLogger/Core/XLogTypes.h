//
//  XLogTypes.h
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 13/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#ifndef XcodeLogger_XLogTypes_h
#define XcodeLogger_XLogTypes_h

typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
    XLOGGER_TYPE_NSLOG,
    XLOGGER_TYPE_DEBUG,
    XLOGGER_TYPE_DEVELOPMENT,
    XLOGGER_TYPE_DEBUG_DEVELOPMENT,
    XLOGGER_TYPE_ONLINE_SERVICES
};

typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
    XLOGGER_LEVEL_SIMPLE,
    XLOGGER_LEVEL_SIMPLE_NO_HEADER,
    XLOGGER_LEVEL_INFORMATION,
    XLOGGER_LEVEL_HIGHLIGHT,
    XLOGGER_LEVEL_WARNING,
    XLOGGER_LEVEL_ERROR,
    XLOGGER_ALL_LEVELS
};

typedef NS_ENUM(unsigned int, XLOGGER_ARGS) {
    XLOGGER_ARGS_TIMESTAMP,
    XLOGGER_ARGS_CALLEE,
    XLOGGER_ARGS_CALLEE_METHOD,
    XLOGGER_ARGS_LINE_NUMBER,
    XLOGGER_ARGS_FILE_NAME
};

#pragma mark - CONVENIENCE MACROS
#define XL_ARG_TIMESTAMP      [NSNumber numberWithUnsignedInt:XLOGGER_ARGS_TIMESTAMP]
#define XL_ARG_CALLEE_ADDRESS [NSNumber numberWithUnsignedInt:XLOGGER_ARGS_CALLEE]
#define XL_ARG_CALLEE_METHOD  [NSNumber numberWithUnsignedInt:XLOGGER_ARGS_CALLEE_METHOD]
#define XL_ARG_LINE_NUMBER    [NSNumber numberWithUnsignedInt:XLOGGER_ARGS_LINE_NUMBER]
#define XL_ARG_FILE_NAME      [NSNumber numberWithUnsignedInt:XLOGGER_ARGS_FILE_NAME]

#define XCODE_COLORS_ESCAPE @"\033["

#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color

#endif
