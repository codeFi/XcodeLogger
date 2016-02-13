# Xcode Logger

[![Version](https://img.shields.io/cocoapods/v/XcodeLogger.svg?style=flat)](http://cocoapods.org/pods/XcodeLogger) 
[![License](https://img.shields.io/cocoapods/l/XcodeLogger.svg?style=flat)](https://github.com/codeFi/XcodeLogger/blob/master/LICENSE) 
[![Platform](https://img.shields.io/cocoapods/p/XcodeLogger.svg?style=flat)](http://cocoapods.org/pods/XcodeLogger)

Xcode Logger is a __fast__ (up to \*6x times faster than *NSLog* and up to 4x times faster than *CocoaLumberjack*), __very simple__ to use, __flexible__ library which provides __scheme dependent__, __customizable__, __filterable__ and __colorful__ *NSLog replacements*.

**based on synchronous serial tests running on main thread, comparing XLog_NH vs NSLog vs DDLogVerbose, average operation time after 5 runs with 5000 iterations per test, per run on a MacBook Pro Retina. Xcode Logger with colors enabled, CocoaLumberjack with ASL (file logging) and colors disabled. Also, the CocoaLumberjack's DDLogVerbose macro was modified to run synchronously.*

---
Xcode Logger has been tested on iOS 7, 8 and OSX. It requires ARC.

<a name="TOC"></a> 
##Documentation
* [Features](#features)
* [How to install](#install)
* [How to use](#use)
 * [Scheme linking](#scheme)
 * [Log Filters](#filters)
 * [Header formatting options](#header)
 * [Color Themes](#themes)
 * [Creating Color Themes](#creatingtheme)
 * [Colors formatting options](#colorformatting)
* [Performance Tests](#performance)
* [Changelog](#changelog)
* [Credits](#credits)

![Xcode Logger - Dracula Theme]
(http://i57.tinypic.com/2it544n.jpg)
(__Dracula__ color theme by [Zeno Rocha](https://github.com/zenorocha/dracula-theme))

##<a name="features"></a> Features
**Xcode Logger** provides multiple types of scheme dependent and independent loggers with multiple levels of logging. It ships by default as plug-and-play with the following types of loggers:     
 - `DLog()`&nbsp;&nbsp;- DEBUG
 - `DVLog()`&nbsp;- DEVELOPMENT
 - `DDLog()`&nbsp;- DEBUG and DEVELOPMENT (a shared log type for both schemes) 
 - `OLog()`&nbsp;&nbsp;- ONLINE SERVICES
 - `XLog()`&nbsp;&nbsp;- NSLog type (replicates **NSLog**'s behaviour: scheme independent.)

Every log type has the following **log levels**:
 - Simple logger (ex: `XLog()`)
 - Simple logger without any header information - `_NH` (ex: `XLog_NH()`)
 - Information logger - `_INFO` (ex: `XLog_INFO()`)
 - Highlight logger - `_IMPORTANT`
 - Warning logger - `_WARNING`
 - Error logger - `_ERROR`

Extremely easy to use, __filterable log levels__. 

__Color Themes__ with UIColor, NSColor and RGB colors support (Themers, you're needed here!).

Almost every log type and level can be can be customized as follows:
- Running scheme (except `XLog` & `DDLog` types).
- Log Informations Header (except `_NH`).
- `NEW` Log status description for all log types and levels (except `_NH`) which can be used as an argument in custom or default headers.
- Text Color for output (overwrite values from the loaded theme).
- Background Color for output (overwrite values from the loaded theme).
- Number of new lines (spaces) between header and output or between output and the next log statement.
- Timestamp format for `timestamp` argument in information header.

[> back to table of contents](#TOC)  

##<a name="install"></a>How to install

### CocoaPods
```
pod 'XcodeLogger'
````

### Manual

Clone or download the repository and add the **Xcode Logger** folder and its contents to your project.

### Setup
1. `Optional:` If you want to have color loggers and you don't have the **Xcode Colors** plugin installed, you will need to [install it](https://github.com/codeFi/XcodeColors).

2. `Optional:` If you want to use the scheme-dependent loggers, you'll need to create schemes based on your needs and link them with the appropriate logger types (see `Scheme linking` under `How to use`). 
Official information regarding **Xcode's schemes** can be found [here](https://developer.apple.com/library/ios/recipes/xcode_help-scheme_editor/Articles/SchemeDialog.html#//apple_ref/doc/uid/TP40010402-CH1-SW1).

3. `Required for #2:`In order for **Xcode Logger** to determine your current scheme, **Xcode** will need to be able to add a value for a `key` in your project's `Info.plist` file when building your project so there are two things you'll need to do: `First`, create a key entry for a `string` value in your `Info.plist` file while leaving the `value` field empty like in the example below:
![Info.plist Key](http://i58.tinypic.com/jszfx0.jpg)
Next you'll need to add the following script to your every scheme under `Build` > `Pre-actions`. Be sure to select a **target** from which to build from! `Tip:` do this before creating any second custom scheme and just duplicate the scheme.

```Shell
#This script will provide that value at runtime.
#You can change "XLRunningScheme" with whatever key name you wish as long as it matches the one from Info.plist.

/usr/libexec/PlistBuddy -c "Set :XLRunningScheme \"$SCHEME_NAME\"" "$PROJECT_DIR/$INFOPLIST_FILE"		
```			

![Add the script to your schema]
(http://i57.tinypic.com/6thddw.jpg)

[> back to table of contents](#TOC)  

##<a name="use"></a>How to use
### `Default Logger`
To start using **Xcode Logger** all you have to do is to `#import "XcodeLogger.h"` in your classes and use the `XLog` type logger with all its levels as a replacement for `NSLog`.

###<a name="scheme"></a>`Scheme Linking`
To start using scheme-dependent loggers you'll need to do the following (considering you've followed the optional but now-required steps from **Setup**):

Tell **Xcode Logger** the name of the `key` you've defined in your `Info.plist` and script by calling:

```Objective-C
[[XcodeLogger sharedManager] setInfoPlistKeyNameForRunningSchemes:@"XLRunningScheme"];
```

Link a running scheme name with a logger type:

```Objective-C
//Example for setting a scheme for DLog type logger
[[XcodeLogger sharedManager] setBuildSchemeName:@"XL Debug"
                             		forXLogType:XLOGGER_TYPE_DEBUG];
```

```Objective-C
XLOGGER_TYPES:

XLOGGER_TYPE_NSLOG_REPLACEMENT, //XLog
XLOGGER_TYPE_DEBUG,             //DLog
XLOGGER_TYPE_DEVELOPMENT,       //DVLog
XLOGGER_TYPE_DEBUG_DEVELOPMENT, //DDLog
XLOGGER_TYPE_ONLINE_SERVICES    //OLog
```

That's it! 

> NOTE: you can't link a scheme with `XLOGGER_TYPE_NSLOG_REPLACEMENT` or `XLOGGER_TYPE_DEBUG_DEVELOPMENT` because of their intended purposes. Doing so, will raise an exception.

###<a name="filters"></a>`Log Filters`
You can filter single or multiple log levels per class (implementation file) or globally.

You have two options: either use a method and set the implementation file name manually or you can use a convenience macro that greatly simplifies the whole process.

```Objective-C
//The following examples will output only warnings and errors

//Example Option 1 
//You can call this almost anywhere (before calling the logs) since you manually set the file name. If you pass nil for file name, the effect will become global.
[[XcodeLogger sharedManager] filterXLogLevels:@[XL_LEVEL_WARNING,XL_LEVEL_ERROR]
                                  forFileName:@"AppDelegate.m"];

//Example Option 2 (LOCAL FILTERS)
//You must call this in the implementation file where you need filters
XL_FILTER_LEVELS(XL_LEVEL_WARNING,XL_LEVEL_ERROR);

//Example Option 3 (GLOBAL FILTERS)
//You should call this as early as possible in your app's lifecycle
XL_FILTER_GLOBAL_LEVELS(XL_LEVEL_WARNING,XL_LEVEL_ERROR);
```
```Objective-C
//Convenience wrappers for XLOGGER_LEVEL_### constants
XL_LEVEL_SIMPLE           
XL_LEVEL_SIMPLE_NO_HEADER 
XL_LEVEL_INFORMATION      
XL_LEVEL_IMPORTANT        
XL_LEVEL_WARNING         
XL_LEVEL_ERROR            
```


###<a name="header"></a>`Header Formatting Options`
You can change the default and customize the informations header for any `XLOGGER_TYPE` and `XLOGGER_LEVEL` like this:

```Objective-C

//NEW: Example for changing the default Log Status Description and Color
[[XcodeLogger sharedManager] setLogHeaderDescription:@"DEVLOG_INFO"
								          forLogType:XLOGGER_TYPE_DEVELOPMENT
								               level:XLOGGER_LEVEL_INFORMATION
								               color:[XLColor redColor];

//Example for changing the informations header for DVLog_INFO()
//This will set the header to show the log description and a timestamp followed by the line number
[[XcodeLogger sharedManager] setHeaderForXLogType:XLOGGER_TYPE_DEVELOPMENT
                          					level:XLOGGER_LEVEL_INFORMATION
                          				   format:@"{%@}->[%@]::[#%@]"
                         				arguments:@[XL_ARG_LOG_DESCRIPTION,XL_ARG_TIMESTAMP,XL_ARG_LINE_NUMBER]];

```
> NOTE: you can use `XLOGGER_ALL_LEVELS` enum to set the same header format for all levels of an `XLOGGER_TYPE`.

```Objective-C
// XLOGGER_LEVELS:

XLOGGER_LEVEL_SIMPLE,          
XLOGGER_LEVEL_SIMPLE_NO_HEADER, //_NH
XLOGGER_LEVEL_INFORMATION,		//_INFO
XLOGGER_LEVEL_IMPORTANT,		//_IMPORTANT
XLOGGER_LEVEL_WARNING,			//_WARNING
XLOGGER_LEVEL_ERROR,			//_ERROR
XLOGGER_ALL_LEVELS

```


```Objective-C
// XL_ARG macros:

XL_ARG_LOG_DESCRIPTION
XL_ARG_TIMESTAMP      
XL_ARG_CALLEE_ADDRESS 
XL_ARG_CALLEE_METHOD  
XL_ARG_LINE_NUMBER    
XL_ARG_FILE_NAME     
```

> NOTE: the default headers contain the following informations (in order):
```
[Logger_Type_Level](Timestamp)=> [>Callee_Memory_Address<]:Callee_File_Name:[#Line_Number]:[>Callee_Method<]
```

If you want you can add or remove new lines (spaces) between the header and the log output by calling:
```Objective-C
- (void)setNumberOfNewLinesAfterHeader:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramXLogType
                                 level:(XLOGGER_LEVEL)paramXLogLevel;

```
Or, add or remove new lines (spaces) between the output and the next log statement by calling:
```Objective-C
- (void)setNumberOfNewLinesAfterOutput:(NSUInteger)paramNumberOfLines
                           forXLogType:(XLOGGER_TYPE)paramXLogType
                                 level:(XLOGGER_LEVEL)paramXLogLevel;

```

You can also change the `timestamp` format by using a valid `NSDateFormatter` format string and by calling:
```Objective-C
//The default is @"HH:mm:ss"
- (void)setTimestampFormat:(NSString *)paramTimestampFormat;
```

[> back to table of contents](#TOC)  

###<a name="themes"></a>`Color Themes`
![Xcode Logger - Dusk Theme]
(http://i61.tinypic.com/24qv4n5.png)
(__Dusk__ color theme based on Xcode's Dusk Theme)

![Xcode Logger - Default Dark Theme]
(http://i57.tinypic.com/9j0snd.png)
(__Dark__ color theme based on Xcode's Midnight Theme)

![Xcode Logger - Solarize Dark Theme]
(http://i61.tinypic.com/mkepnl.png)
(__Solarize Dark__ color theme by [Jason Brennan](https://github.com/jbrennan/xcode4themes))

![Xcode Logger - Solarize Light Theme]
(http://i58.tinypic.com/33dbkfl.png)
(__Solarize Light__ color theme by [Jason Brennan](https://github.com/jbrennan/xcode4themes))

![Xcode Logger - Default Light Theme]
(http://i60.tinypic.com/ofygra.png)
(__Light__ color theme based on Xcode's Default Theme)

Xcode Logger uses color themes for its log types and levels. 
It comes with `six default themes` and you can very easily create your own.

Different color themes can be used in different classes.

You can check the available themes by calling 
```Objective-C
- (void)printAvailableColorThemes;
```
You can load a theme by calling:
```Objective-C
//paramColorThemeName is case-insensitive
- (void)loadColorThemeWithName:(NSString *)paramColorThemeName;
```

For convenience, there are two constants defined for the default themes in `XcodeLogger.h`:
```Objective-C
// THE DEFAULT COLOR THEMES FOR XCODE LOGGER
// YOU'RE INVITED TO ADD(CREATE) MORE HERE AND SEND A PULL REQUEST (check -[printColorThemeCreationInstructions])

XLCT_DEFAULT_LIGHT_THEME  //based on Xcode's Default Theme
XLCT_DEFAULT_DUSK_THEME   //based on Xcode's Dusk Theme
XLCT_DEFAULT_DARK_THEME   //based on Xcode's Midnight Theme
XLCT_SOLARIZE_LIGHT_THEME //Based on Solarize Light Theme by Jason Brennan https://github.com/jbrennan/xcode4themes
XLCT_SOLARIZE_DARK_THEME  //Based on Solarize Dark Theme by Jason Brennan https://github.com/jbrennan/xcode4themes
XLCT_DRACULA_THEME        //Based on Dracula Theme by Zeno Rocha https://github.com/zenorocha/dracula-theme
```

> NOTE: Xcode Logger loads `DEFAULT_LIGHT_THEME` by default so you don't have to call `loadColorThemeWithName:` if you're not interested in changing the theme.

####<a name="creatingtheme"></a>Creating Color Themes

All Xcode Logger's themes are defined in `XLColorThemes.plist` file where you can find two `sample themes` next to the default ones.

All you have to do is to duplicate those samples, rename and modify them accordingly while preserving the `keys` for every `dictionary` __except__ the `root dictionary key` which is the theme's name.

You can use either RGB values separated by whitespace or `,./-*+` or you can use `UIColor/NSColor` selectors like this `blackColor`.

When you add a new theme in `XLColorThemes.plist` it would be cool if you add a constant for its name like the default ones (please use the `XLCT_` prefix).

You also have detailed `theme creation instructions` by calling:
```Objective-C
[[XcodeLogger sharedManager] printColorThemeCreationInstructions];
```

[> back to table of contents](#TOC)  

###<a name="colorformatting"></a>`Colors Formatting Options`
You can enable or disable support for color logs and change the text and background colors of the body of the output (headers excluded) independently of the currently loaded color theme (if it's loaded before making a color change).

By default, colors are enabled but you can change this by calling:
```Objective-C
- (void)setColorLogsEnabled:(BOOL)paramEnableColors;
```

You can set the text color for the output by calling:
```Objective-C
//XLColor is a convenience macro for cross platform
//compatibility between iOS (UIColor) and OSX (NSColor)
- (void)setTextColor:(XLColor *)paramTextColor
         forXLogType:(XLOGGER_TYPE)paramLogType
               level:(XLOGGER_LEVEL)paramLogLevel;
```
```Objective-C
- (void)setTextColorForXLogType:(XLOGGER_TYPE)paramXLogType
                          level:(XLOGGER_LEVEL)paramXLogLevel
                        withRed:(NSUInteger)red
                          Green:(NSUInteger)green
                           Blue:(NSUInteger)blue;
```

And you can set the background color for the output by calling:
```Objective-C
//XLColor is a convenience macro for cross platform
//compatibility between iOS (UIColor) and OSX (NSColor)
- (void)setBackgroundColor:(XLColor *)paramBackgroundColor
               forXLogType:(XLOGGER_TYPE)paramLogType
                     level:(XLOGGER_LEVEL)paramLogLevel
```
```Objective-C
- (void)setBackgroundColorForXLogType:(XLOGGER_TYPE)paramXLogType
                                level:(XLOGGER_LEVEL)paramXLogLevel
                              withRed:(NSUInteger)red
                                Green:(NSUInteger)green
                                 Blue:(NSUInteger)blue;
```   

[> back to table of contents](#TOC)   

###<a name="performance"></a>Performance Tests

![Xcode Logger Performance: Synchronous Tests]
(http://i.imgur.com/MgXsE94.jpg?1)
![Xcode Logger Performance: Asynchronous Tests]
(http://i.imgur.com/xlmpt2G.jpg)

`Xcode Logger` comes with a class called `XLPerformanceTests`. You can use its public methods to test `Xcode Logger`.

### Code Samples
This repository contains code samples for both `iOS` and `OSX`.   
These are GREAT to see and test some examples for uses of __Xcode Logger__.  
You can find them in the master folder after cloning or downloading the repository.

###<a name="changelog"></a>Changelog:
`Version 1.2.2:`
* Code maintenance.

`Version 1.2.1:`
* Added a global filter option through the `XL_FILTER_GLOBAL_LEVELS` macro
* A minor addition to `XLogObject` class which isn't used at this moment (the `dealloc` method) 

`Version 1.2.0:`  
* More refactoring
* `_HIGHLIGHT` log level renamed to `_IMPORTANT`
* Fixed some issues regarding Logs Header Descriptions
* Deprecated `setLogHeaderDescription:forLogType:level:`
* New method `setLogHeaderDescription:forLogType:level:color:`   
* New & Updated Color Themes
* Added the option to set the same header format for all Log Types for a given level    
* Added the option to set the same log header description for all Log Types for a given level
* Added the option to set the same text color for all Log Types for a given level
* Added the option to set the same background color for all Log Types for a given level
* Other minor improvements
* Fixed other issues throughout the library

`Version 1.1.1:`  
* LOTS & LOTS of refactoring!
* Log Filters  
* Color Themes   
* UIColor / NSColor support
* Log status description customization options

[> back to table of contents](#TOC)  

----

###<a name="credits"></a>Author
This library was created and made open-source by [Razvan Tanase](https://ro.linkedin.com/in/ratanase).

You can also find me on Twitter [@razvan_tanase](https://twitter.com/razvan_tanase).

I highly appreciate any feedback, positive and/or constructive so I can improve this project.

###Contributors
__Solarize Light__ & __Dark__ themes based on the work of Jason Brennan https://github.com/jbrennan/xcode4themes.  
__Dracula__ theme based on the work of Zeno Rocha https://github.com/zenorocha/dracula-theme.

###License
__You're more than welcome to contribute to this project!__ When you have a change you’d like to see in the master repository, please [send a pull request](https://github.com/codeFi/XcodeLogger/pulls).

The MIT License (MIT) Copyright © 2015 Razvan Tanase ([Codebringers Software](http://codebringers.com)).
