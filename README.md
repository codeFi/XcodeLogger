# Xcode Logger

[![Version](https://img.shields.io/cocoapods/v/XcodeLogger.svg?style=flat)](http://cocoapods.org/pods/XcodeLogger) 
[![License](https://img.shields.io/cocoapods/l/XcodeLogger.svg?style=flat)](https://github.com/codeFi/XcodeLogger/blob/master/LICENSE) 
[![Platform](https://img.shields.io/cocoapods/p/XcodeLogger.svg?style=flat)](http://cocoapods.org/pods/XcodeLogger)

**Xcode Logger** is a fast (up to *35x times faster than NSLog), very __simple__ to use, __flexible__ library which provides __scheme-based__, __customizable__ and __colorful__ (using the [Xcode Colors](https://github.com/codeFi/XcodeColors) plugin) __NSLog replacements__.

**based on tests comparing NSLog vs XLog's No Header level, average operation time after 5 runs with 5000 iterations per test, per run on a MacBook Pro Retina.*

---
Xcode Logger has been tested on iOS 7, 8 and OSX. It requires ARC.
![Xcode Logger]
(http://i58.tinypic.com/6700f4.png)
![Xcode Logger Performance: MacBook Pro]
(http://i58.tinypic.com/jsh9vm.jpg)
![Xcode Logger Performance: iPhone 4S]
(http://i62.tinypic.com/118epo0.jpg)

## Features
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
 - Highlight logger - `_HIGHLIGHT`
 - Warning logger - `_WARNING`
 - Error logger - `_ERROR`

Almost every log type and level can be can be customized as follows:
- Running scheme (except `XLog` & `DDLog` types)
- Header Information (except `_NH`)
- Text Color for output (exclusive)
- Background Color for output (exclusive)
- Number of new lines (spaces) between header and output or between output and the next log statement.
- Timestamp format for `timestamp` argument in information header

## How to install

### Cocoapods
```
pod 'XcodeLogger'
````

### Manual

Download or clone the repository and add the **Xcode Logger** folder and its contents to your project. Select `Copy files if needed`.
![Copy Xcode Logger into your project]
(http://i60.tinypic.com/jgjiw9.jpg) 

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
## How to use
### `Default Logger`
To start using **Xcode Logger** all you have to do is to `#import "XcodeLogger.h"` in your classes and use the `XLog` type logger with all its levels as a replacement for `NSLog`.

### `Scheme Linking`
To start using scheme-dependent loggers you'll need to do the following (considering you've followed the optional but now-required steps from **Setup**):

Tell **Xcode Logger** the name of the `key` you've defined in your `Info.plist` and script by calling:

```Objective-C
[[XcodeLogger sharedManager] setInfoPlistKeyNameForRunningSchemes:@"XLRunningScheme"];
```

Link a running scheme name with a logger type:

```Objective-C
//Example for setting a schema for DLog type logger
[[XcodeLogger sharedManager] setBuildSchemeName:@"XL Debug"
                             		forXLogType:XLOGGER_TYPE_DEBUG];
```

```Objective-C
// XLOGGER_TYPES:
typedef NS_ENUM(unsigned int, XLOGGER_TYPE) {
    XLOGGER_TYPE_NSLOG,            //XLog
    XLOGGER_TYPE_DEBUG,            //DLog
    XLOGGER_TYPE_DEVELOPMENT,      //DVLog
    XLOGGER_TYPE_DEBUG_DEVELOPMENT,//DDLog
    XLOGGER_TYPE_ONLINE_SERVICES   //OLog
};

```

That's it! 

> NOTE: you can't link a scheme with `XLOGGER_TYPE_NSLOG` or `XLOGGER_TYPE_DEBUG_DEVELOPMENT` because of their intended purposes. Doing so, will raise an exception.

### `Header Formatting Options`
You can change the default and customize the informations header for any `XLOGGER_TYPE` and `XLOGGER_LEVEL` like this:

```Objective-C
//Example for changing the informations header for DVLog_INFO()
//This will set the header to show a timestamp followed by the line number
[[XcodeLogger sharedManager] setHeaderForXLogType:XLOGGER_TYPE_DEVELOPMENT
                          					level:XLOGGER_LEVEL_INFORMATION
                          				   format:@"[%@]::[#%@]"
                         				arguments:@[XL_ARG_TIMESTAMP, XL_ARG_LINE_NUMBER]];

```
> NOTE: you can use `XLOGGER_ALL_LEVELS` enum to set the same header format for all levels of an `XLOGGER_TYPE`.

```Objective-C
// XLOGGER_LEVELS
 typedef NS_ENUM(unsigned int, XLOGGER_LEVEL) {
    XLOGGER_LEVEL_SIMPLE,          
    XLOGGER_LEVEL_SIMPLE_NO_HEADER, //_NH
    XLOGGER_LEVEL_INFORMATION,		//_INFO
    XLOGGER_LEVEL_HIGHLIGHT,		//_HIGHLIGHT
    XLOGGER_LEVEL_WARNING,			//_WARNING
    XLOGGER_LEVEL_ERROR,			//_ERROR
    XLOGGER_ALL_LEVELS
};

```


```Objective-C
// XL_ARG macros:
#define XL_ARG_TIMESTAMP      
#define XL_ARG_CALLEE_ADDRESS 
#define XL_ARG_CALLEE_METHOD  
#define XL_ARG_LINE_NUMBER    
#define XL_ARG_FILE_NAME     
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

### `Colors Formatting Options`
You can enable or disable support for color logs and change the text and background colors of the body of the output (headers excluded).

By default, colors are enabled but you can change this by calling:
```Objective-C
- (void)setColorLogsEnabled:(BOOL)paramEnableColors;
```

You can set the text color for the output by calling:
```Objective-C
- (void)setTextColorForXLogType:(XLOGGER_TYPE)paramXLogType
                          level:(XLOGGER_LEVEL)paramXLogLevel
                        withRed:(NSUInteger)red
                          Green:(NSUInteger)green
                           Blue:(NSUInteger)blue;
```

You can set the background color for the output by calling:
```Objective-C
- (void)setBackgroundColorForXLogType:(XLOGGER_TYPE)paramXLogType
                                level:(XLOGGER_LEVEL)paramXLogLevel
                              withRed:(NSUInteger)red
                                Green:(NSUInteger)green
                                 Blue:(NSUInteger)blue;
```

### Performance Tests
`Xcode Logger` comes with a class called `XLPerformanceTests`. You can use its public methods to test `Xcode Logger`.

### Code Samples
This repository contains code samples for both `iOS` and `OSX`. You can find them in the master folder after cloning or downloading the repository.

----

#### Author
This library was created and made open-source by [Razvan Tanase](https://ro.linkedin.com/in/ratanase).

You can also find me on Twitter [@razvan_tanase](https://twitter.com/razvan_tanase).

#### License
You're more than welcome to contribute to this project! When you have a change you’d like to see in the master repository, please [send a pull request](https://github.com/codeFi/XcodeLogger/pulls).

The MIT License (MIT) Copyright © 2015 Razvan Tanase ([Codebringers Software](http://codebringers.com)).
