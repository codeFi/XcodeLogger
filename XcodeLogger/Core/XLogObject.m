//
//  XLogObject.m
//  XcodeLogger
//
//  Created by Razvan Alin Tanase on 13/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import "XLogObject.h"

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

static NSString *const DEFAULT_STATUS_TEXT_COLOR_WARNING = @"fg255,98,0;";

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
                    _headerArguments = @[[self logTypeStringForHeaderFromType:paramLogType
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

- (NSString *)logTypeStringForHeaderFromType:(XLOGGER_TYPE)paramXLogType level:(XLOGGER_LEVEL)paramXLogLevel
{
    switch (paramXLogType)
    {
        case XLOGGER_TYPE_DEBUG:
        {
            switch (paramXLogLevel)
            {
                case XLOGGER_LEVEL_SIMPLE:
                    return STATUS_DLOG_SIMPLE;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_INFO_LEVEL],
                            STATUS_DLOG_INFO,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL],
                            STATUS_DLOG_HIGHLIGHT,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [NSString stringWithFormat:@"%@%@%@%@",
                            XCODE_COLORS_ESCAPE,
                            DEFAULT_STATUS_TEXT_COLOR_WARNING,
                            STATUS_DLOG_WARNING,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_ERROR_LEVEL],
                            STATUS_DLOG_ERROR,
                            XCODE_COLORS_RESET];
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
                    return STATUS_DVLOG_SIMPLE;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_INFO_LEVEL],
                            STATUS_DVLOG_INFO,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL],
                            STATUS_DVLOG_HIGHLIGHT,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [NSString stringWithFormat:@"%@%@%@%@",
                            XCODE_COLORS_ESCAPE,
                            DEFAULT_STATUS_TEXT_COLOR_WARNING,
                            STATUS_DVLOG_WARNING,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_ERROR_LEVEL],
                            STATUS_DVLOG_ERROR,
                            XCODE_COLORS_RESET];
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
                    return STATUS_DDLOG_SIMPLE;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_INFO_LEVEL],
                            STATUS_DDLOG_INFO,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL],
                            STATUS_DDLOG_HIGHLIGHT,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [NSString stringWithFormat:@"%@%@%@%@",
                            XCODE_COLORS_ESCAPE,
                            DEFAULT_STATUS_TEXT_COLOR_WARNING,
                            STATUS_DDLOG_WARNING,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_ERROR_LEVEL],
                            STATUS_DDLOG_ERROR,
                            XCODE_COLORS_RESET];
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
                    return STATUS_OLOG_SIMPLE;
                    break;
                case XLOGGER_LEVEL_INFORMATION:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_INFO_LEVEL],
                            STATUS_OLOG_INFO,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_HIGHLIGHT:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_HIGHLIGHT_LEVEL],
                            STATUS_OLOG_HIGHLIGHT,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_WARNING:
                    return [NSString stringWithFormat:@"%@%@%@%@",
                            XCODE_COLORS_ESCAPE,
                            DEFAULT_STATUS_TEXT_COLOR_WARNING,
                            STATUS_OLOG_WARNING,
                            XCODE_COLORS_RESET];
                    break;
                case XLOGGER_LEVEL_ERROR:
                    return [NSString stringWithFormat:@"%@%@%@",
                            [self convertBackgroundColorToText:DEFAULT_BGRD_COLOR_ERROR_LEVEL],
                            STATUS_OLOG_ERROR,
                            XCODE_COLORS_RESET];
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

@end
