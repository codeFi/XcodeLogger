//
//  AppDelegate.m
//  XcodeLogger-iOS-Sample
//
//  Created by Razvan Alin Tanase on 15/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.


#import "AppDelegate.h"
#import "XcodeLogger.h"
#import "XLPerformanceTests.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*
     * Required for iOS Projects to enable the Xcode Colors plugin.
     *
     * If the plugin is not installed, the output will contain the colors escape strings.
     * If the plugin is installed but not loaded, either update the plugin
     * to the newest version containing the latest Xcode's UDID or do it
     * yourself: https://github.com/robbiehanson/XcodeColors/wiki/XcodeUpdates
     *
     * The line below is needed for enabling colors when running on device.
     *
     * If you encounter any issues with Xcode Colors,
     * comment the line below or set the variable to NO.
     *
     */
    setenv("XcodeColors", "YES", 0);
    
    /****** CHECK XcodeLogger.h for reference ******/
    
    /* Grab a reference to Xcode Logger singleton instance */
    XcodeLogger *xManager = [XcodeLogger sharedManager];
    
    [xManager loadColorThemeWithName:XLCT_DEFAULT_DUSK_THEME];
    
    
    /* Check Info.plist and README to see why the line below */
    [xManager setInfoPlistKeyNameForRunningSchemes:@"XLRunningScheme"];
    
    /*
     * Scheme Linking - case insensitive
     * Sets scheme "XL DEBUG" as the running scheme for DLog
     */
    [xManager setBuildSchemeName:@"xl debug"
                     forXLogType:XLOGGER_TYPE_DEBUG];
    
    /* Sets scheme "XL DEVELOPMENT" as the running scheme for DVLog */
    [xManager setBuildSchemeName:@"xl development"
                     forXLogType:XLOGGER_TYPE_DEVELOPMENT];
    
    /* Sets scheme "XL ONLINE" as the running scheme for OLog */
    [xManager setBuildSchemeName:@"xl online"
                     forXLogType:XLOGGER_TYPE_ONLINE_SERVICES];
    
    
    /* PRINT Xcode Logger Theme Creation Instructions */
    //    [xManager printColorThemeCreationInstructions];
    
    /* PRINT Xcode Logger's Available Color Themes */
    //    [xManager printAvailableColorThemes];
    
    
    /*
     * Changes the default text color for DLog_INFO (global effect)
     * XLColor macro is cross platform (either NSColor or UIColor)
     * You can pass nil to disable the color.
     * If both text & background colors are nil, Xcode Logger will fallback
     * to the loaded color theme's colors for both properties
     */
    //    [xManager setTextColor:[XLColor whiteColor]
    //               forXLogType:XLOGGER_TYPE_DEBUG
    //                     level:XLOGGER_LEVEL_INFORMATION];
    
    /*
     * Changes the default background color for DLog_INFO (global effect)
     * XLColor macro is cross platform (either NSColor or UIColor)
     * You can pass nil to disable the color.
     * If both text & background colors are nil, Xcode Logger will fallback
     * to the loaded color theme's colors for both properties
     */
    //    [xManager setBackgroundColor:[XLColor blackColor]
    //                     forXLogType:XLOGGER_TYPE_DEBUG
    //                           level:XLOGGER_LEVEL_INFORMATION];
    
    /*
     * Changes the default log header description for DDLog_INFO (global effect)
     *
     * In case there's no XLColor passed as a parameter, this property takes its color
     * from either background or text colors of the output.
     *
     * It tries to get the color from the background color property first, if that's nil,
     * it will take it from the text color property.
     *
     * In case you specify an XLColor, the color of the Log Description will not be changed
     * if you load a different color theme later.
     */
    //    [xManager setLogHeaderDescription:@"TEST_LOG_STATUS"
    //                           forLogType:XLOGGER_TYPE_ALL
    //                                level:XLOGGER_LEVEL_IMPORTANT
    //                                color:[XLColor whiteColor]];
    
    /*
     * The calls below are changing the default log header descriptions for
     * ALL LOG TYPES-INFORMATION LEVEL, DLog_IMPORTANT, DLog_WARNING, ALL LOG TYPES-ERROR LEVEL
     *
     * This property takes its color from either background or text colors of the output.
     * It tries to get the color from the background color property first, if that's nil,
     * it will take it from the text color property.
     */
    [xManager setLogHeaderDescription:@"INFO:📝"
                           forLogType:XLOGGER_TYPE_DEBUG
                                level:XLOGGER_LEVEL_INFORMATION
                                color:nil];
    [xManager setLogHeaderDescription:@"DEBUG:💡"
                           forLogType:XLOGGER_TYPE_DEBUG
                                level:XLOGGER_LEVEL_IMPORTANT
                                color:nil];
    [xManager setLogHeaderDescription:@"DEBUG:⚠️"
                           forLogType:XLOGGER_TYPE_DEBUG
                                level:XLOGGER_LEVEL_WARNING
                                color:nil];
    [xManager setLogHeaderDescription:@"DEBUG:❌"
                           forLogType:XLOGGER_TYPE_DEBUG
                                level:XLOGGER_LEVEL_ERROR
                                color: nil];
    
    /*
     * Changes the default log information header for DDLog_INFO (global effect)
     * In this example,XL_ARG_LOG_DESCRIPTION argument uses either the default
     * log header description or a custom string if defined (see above)
     */
    //        [xManager setHeaderForXLogType:XLOGGER_TYPE_DEBUG_DEVELOPMENT
    //                                 level:XLOGGER_LEVEL_INFORMATION
    //                                format:@"{%@}"
    //                             arguments:@[XL_ARG_LOG_DESCRIPTION]];
    
    /*
     *  XL_FILTER_LEVELS() or -[filterXLogLevels:forFileName:] are filtering the log levels.
     *  XL_FILTER_LEVELS() is convenience macro for -[filterXLogLevels:forFileName:]
     *  Check the HeaderDoc comment for -[filterXLogLevels:forFileName:]
     *  Here it shows only Simple and Error Levels
     *  Has a local effect. Call it in the classes where you want your levels filtered.
     *
     *  Uncomment the line below to see its effects.
     *
     */
    
    //     XL_FILTER_LEVELS( XL_LEVEL_SIMPLE, XL_LEVEL_ERROR );
    
    
    /************************ DEMOS ************************/
    
    //XLog - the 1:1 replacement for NSLog
    XLog_NH(@"\n\n-----------------------------------------------------------XLog-----------------------------------------------------------");
    XLog_NH(@"-----------------------------------------------The 1:1 replacement for NSLog----------------------------------------------\n\n");
    
    XLog          (@"XLog()           ~~> NSLog REPLACEMENT WITH A HEADER             - RUNS INDEPENDENT OF ANY SCHEME");
    XLog_NH       (@"XLog_NH()        ~~> NSLog REPLACEMENT WITHOUT A HEADER          - RUNS INDEPENDENT OF ANY SCHEME");
    XLog_INFO     (@"XLog_INFO()      ~~> NSLog REPLACEMENT FOR GENERAL INFORMATION   - RUNS INDEPENDENT OF ANY SCHEME");
    XLog_IMPORTANT(@"XLog_IMPORTANT() ~~> NSLog REPLACEMENT FOR IMPORTANT INFORMATION - RUNS INDEPENDENT OF ANY SCHEME");
    XLog_WARNING  (@"XLog_WARNING()   ~~> NSLog REPLACEMENT FOR WARNINGS              - RUNS INDEPENDENT OF ANY SCHEME");
    XLog_ERROR    (@"XLog_ERROR()     ~~> NSLog REPLACEMENT FOR ERRORS                - RUNS INDEPENDENT OF ANY SCHEME");
    
    
    /*
     * EXAMPLE WITH A DIFFERENT THEME
     * You can use a single color theme globally or
     * load a different theme per implementation file
     */
    //     [xManager loadColorThemeWithName: XLCT_DEFAULT_DARK_THEME];
    
    //DLog - should be linked with a debug scheme
    DLog_NH(@"\n\n-----------------------------------------------------------DLog-----------------------------------------------------------");
    DLog_NH(@"-------------------------------------------Should be linked with a Debug scheme-------------------------------------------\n\n");
    
    DLog          (@"DLog()           ~~> LOGGER FOR A DEBUG SCHEME WITH A HEADER             - RUNS ONLY ON A DEFINED SCHEME");
    DLog_NH       (@"DLog_NH()        ~~> LOGGER FOR A DEBUG SCHEME WITHOUT A HEADER          - RUNS ONLY ON A DEFINED SCHEME");
    DLog_INFO     (@"DLog_INFO()      ~~> LOGGER FOR A DEBUG SCHEME FOR GENERAL INFORMATION   - RUNS ONLY ON A DEFINED SCHEME");
    DLog_IMPORTANT(@"DLog_IMPORTANT() ~~> LOGGER FOR A DEBUG SCHEME FOR IMPORTANT INFORMATION - RUNS ONLY ON A DEFINED SCHEME");
    DLog_WARNING  (@"DLog_WARNING()   ~~> LOGGER FOR A DEBUG SCHEME FOR WARNINGS              - RUNS ONLY ON A DEFINED SCHEME");
    DLog_ERROR    (@"DLog_ERROR()     ~~> LOGGER FOR A DEBUG SCHEME FOR ERRORS                - RUNS ONLY ON A DEFINED SCHEME");
    
    
    //DVLog - should be linked with a development scheme
    DVLog_NH(@"\n\n-----------------------------------------------------------DVLog-----------------------------------------------------------");
    DVLog_NH(@"----------------------------------------Should be linked with a Development scheme-----------------------------------------\n\n");
    
    DVLog          (@"DVLog()           ~~> LOGGER FOR A DEVELOPMENT SCHEME WITH A HEADER             - RUNS ONLY ON A DEFINED SCHEME");
    DVLog_NH       (@"DVLog_NH()        ~~> LOGGER FOR A DEVELOPMENT SCHEME WITHOUT A HEADER          - RUNS ONLY ON A DEFINED SCHEME");
    DVLog_INFO     (@"DVLog_INFO()      ~~> LOGGER FOR A DEVELOPMENT SCHEME FOR GENERAL INFORMATION   - RUNS ONLY ON A DEFINED SCHEME");
    DVLog_IMPORTANT(@"DVLog_IMPORTANT() ~~> LOGGER FOR A DEVELOPMENT SCHEME FOR IMPORTANT INFORMATION - RUNS ONLY ON A DEFINED SCHEME");
    DVLog_WARNING  (@"DVLog_WARNING()   ~~> LOGGER FOR A DEVELOPMENT SCHEME FOR WARNINGS              - RUNS ONLY ON A DEFINED SCHEME");
    DVLog_ERROR    (@"DVLog_ERROR()     ~~> LOGGER FOR A DEVELOPMENT SCHEME FOR ERRORS                - RUNS ONLY ON A DEFINED SCHEME");
    
    
    //    [xManager loadColorThemeWithName: XLCT_DEFAULT_DUSK_THEME];
    
    
    //DDLog - it's automatically used with both debug and development schemes. No manual linking required.
    //It's useful for having a shared output between both schemes but striped away when releasing the app.
    DDLog_NH(@"\n\n-----------------------------------------------------------DDLog-----------------------------------------------------------");
    DDLog_NH(@"---------------It's automatically used with both Debug and Development schemes. No manual linking required.----------------\n\n");
    
    DDLog          (@"DDLog()           ~~> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES WITH A HEADER             - RUNS ON BOTH D&DV SCHEMES");
    DDLog_NH       (@"DDLog_NH()        ~~> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES WITHOUT A HEADER          - RUNS ON BOTH D&DV SCHEMES");
    DDLog_INFO     (@"DDLog_INFO()      ~~> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR GENERAL INFORMATION   - RUNS ON BOTH D&DV SCHEMES");
    DDLog_IMPORTANT(@"DDLog_IMPORTANT() ~~> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR IMPORTANT INFORMATION - RUNS ON BOTH D&DV SCHEMES");
    DDLog_WARNING  (@"DDLog_WARNING()   ~~> SHARED LOGGER DEBUG & DEVELOPMENT SCHEMES FOR WARNINGS                  - RUNS ON BOTH D&DV SCHEMES");
    DDLog_ERROR    (@"DDLog_ERROR()     ~~> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR ERRORS                - RUNS ON BOTH D&DV SCHEMES");
    
    
    //OLog - should be linked with a scheme that's debugging online services
    OLog_NH(@"\n\n-----------------------------------------------------------OLog-----------------------------------------------------------");
    OLog_NH(@"------------------------------Should be linked with a scheme that's debugging online services-----------------------------\n\n");
    
    OLog          (@"OLog           ~~> LOGGER FOR A NETWORK SERVICES DEBUGGING SCHEME WITH A HEADER             - RUNS ONLY ON A DEFINED SCHEME");
    OLog_NH       (@"OLog_NH        ~~> LOGGER FOR A NETWORK SERVICES DEBUGGING SCHEME WITHOUT A HEADER          - RUNS ONLY ON A DEFINED SCHEME");
    OLog_INFO     (@"OLog_INFO      ~~> LOGGER FOR A NETWORK SERVICES DEBUGGING SCHEME FOR GENERAL INFORMATION   - RUNS ONLY ON A DEFINED SCHEME");
    OLog_IMPORTANT(@"OLog_IMPORTANT ~~> LOGGER FOR A NETWORK SERVICES DEBUGGING SCHEME FOR IMPORTANT INFORMATION - RUNS ONLY ON A DEFINED SCHEME");
    OLog_WARNING  (@"OLog_WARNING   ~~> LOGGER FOR A NETWORK SERVICES DEBUGGING SCHEME FOR WARNINGS              - RUNS ONLY ON A DEFINED SCHEME");
    OLog_ERROR    (@"OLog_ERROR     ~~> LOGGER FOR A NETWORK SERVICES DEBUGGING SCHEME FOR ERRORS                - RUNS ONLY ON A DEFINED SCHEME");
    
    
    
    /************************ Performance Tests (synchronous) ************************/
    
    /*
     * If you have CocoaLumberjack, uncomment ENABLE_COCOALUMBERJACK macro in XLPerformanceTests.h
     * and in the DDLogMacros.h file, change the LOG_ASYNC_ENABLED flag for DDLogVerbose to NO
     * because it crashes the test
     */
    
    //    [XLPerformanceTests startPerformanceTestWithNumberOfRuns:5
    //                                          numberOfIterations:1000];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
