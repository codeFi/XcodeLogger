//
//  AppDelegate.m
//  XcodeLogger-OSX-Sample
//
//  Created by Razvan Alin Tanase on 15/07/15.
//  Copyright (c) 2015 Codebringers Software. All rights reserved.
//

#import "AppDelegate.h"
#import "XcodeLogger.h"
#import "XLPerformanceTests.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    /****** CHECK XcodeLogger.h ******/
    
    //grab a reference to Xcode Logger singleton instance
    XcodeLogger *xManager = [XcodeLogger sharedManager];
    
    //    [xManager loadColorThemeWithName:XLCT_DEFAULT_DARK_THEME];
    
    //PRINT Xcode Logger Theme Creation Instructions
    //    [xManager printColorThemeCreationInstructions];
    
    //PRINT Xcode Logger's Available Color Themes
    //    [xManager printAvailableColorThemes];
    
    //check Info.plist and README to see why
    [xManager setInfoPlistKeyNameForRunningSchemes:@"XLRunningScheme"];
    
    //scheme linking - case insensitive
    //sets scheme "XL DEBUG" as the running scheme for DLog
    [xManager setBuildSchemeName:@"xl debug"
                     forXLogType:XLOGGER_TYPE_DEBUG];
    
    //sets scheme "XL DEVELOPMENT" as the running scheme for DVLog
    [xManager setBuildSchemeName:@"xl development"
                     forXLogType:XLOGGER_TYPE_DEVELOPMENT];
    
    //sets scheme "XL ONLINE" as the running scheme for OLog
    [xManager setBuildSchemeName:@"xl online"
                     forXLogType:XLOGGER_TYPE_ONLINE_SERVICES];
    
    //    //changes the default text color for XLog simple (global effect)
    //    //XLColor macro is cross platform (either NSColor or UIColor)
    //    [xManager setTextColor:[XLColor greenColor]
    //               forXLogType:XLOGGER_TYPE_NSLOG_REPLACEMENT
    //                     level:XLOGGER_LEVEL_SIMPLE];
    //
    //    //changes the default background color for XLog simple (global effect)
    //    //XLColor macro is cross platform (either NSColor or UIColor)
    //    [xManager setBackgroundColor:[XLColor blackColor]
    //                     forXLogType:XLOGGER_TYPE_NSLOG_REPLACEMENT
    //                           level:XLOGGER_LEVEL_SIMPLE];
    
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
    
    //XLog - the 1:1 replacement for NSLog
    XLog_NH(@"\n\n--------------------------------------XLog--------------------------------------------------");
    XLog_NH(@"---------------------------The 1:1 replacement for NSLog------------------------------------\n\n");
    
    XLog(@"<* XLog *> SIMPLE NSLog REPLACEMENT WITH HEADER - RUNS INDEPENDENTLY OF CURRENT SCHEME");
    XLog_NH(@"<* XLog_NH *> SIMPLE NSLog REPLACEMENT WITHOUT HEADER - RUNS INDEPENDENTLY OF CURRENT SCHEME");
    XLog_INFO(@"<* XLog_INFO *> SIMPLE NSLog REPLACEMENT FOR INFORMATION - RUNS INDEPENDENTLY OF CURRENT SCHEME");
    XLog_HIGHLIGHT(@"<* XLog_HIGHLIGHT *> SIMPLE NSLog REPLACEMENT FOR HIGHLIGHT - RUNS INDEPENDENTLY OF CURRENT SCHEME");
    XLog_WARNING(@"<* XLog_WARNING *> SIMPLE NSLog REPLACEMENT FOR WARNINGS - RUNS INDEPENDENTLY OF CURRENT SCHEME");
    XLog_ERROR(@"<* XLog_ERROR *> SIMPLE NSLog REPLACEMENT FOR ERRORS - RUNS INDEPENDENTLY OF CURRENT SCHEME");
    
    
    // EXAMPLE WITH A DIFFERENT THEME
    // You can theme Xcode Logger globally per app or locally per file.
    //   [xManager loadColorThemeWithName: XLCT_DEFAULT_DARK_THEME];
    
    //DLog - should be linked with a debug scheme
    DLog_NH(@"\n\n--------------------------------------DLog--------------------------------------------------");
    DLog_NH(@"------------------------Should be linked with a Debug scheme--------------------------------\n\n");
    
    DLog(@"<* DLog *> LOGGER FOR A DEBUG SCHEME - RUNS ONLY ON A DEBUG SCHEME");
    DLog_NH(@"<* DLog_NH *> LOGGER FOR A DEBUG SCHEME WITHOUT HEADER - RUNS ONLY ON A DEBUG SCHEME");
    DLog_INFO(@"<* DLog_INFO *> LOGGER FOR A DEBUG SCHEME FOR INFORMATION - RUNS ONLY ON A DEBUG SCHEME");
    DLog_HIGHLIGHT(@"<* DLog_HIGHLIGHT *> LOGGER FOR A DEBUG SCHEME FOR HIGHLIGHT - RUNS ONLY ON A DEBUG SCHEME");
    DLog_WARNING(@"<* DLog_WARNING *> LOGGER FOR A DEBUG SCHEME FOR WARNINGS - RUNS ONLY ON A DEBUG SCHEME");
    DLog_ERROR(@"<* DLog_ERROR *> LOGGER FOR A DEBUG SCHEME FOR ERRORS - RUNS ONLY ON A DEBUG SCHEME");
    
    
    //DVLog - should be linked with a development scheme
    DVLog_NH(@"\n\n-------------------------------------DVLog-------------------------------------------------");
    DVLog_NH(@"----------------------Should be linked with a Development scheme---------------------------\n\n");
    
    DVLog(@"<* DVLog *> LOGGER FOR A DEVELOPMENT SCHEME - RUNS ONLY ON A DEVELOPMENT SCHEME");
    DVLog_NH(@"<* DVLog_NH *> LOGGER FOR A DEVELOPMENT SCHEME WITHOUT HEADER - RUNS ONLY ON A DEVELOPMENT SCHEME");
    DVLog_INFO(@"<* DVLog_INFO *> LOGGER FOR A DEVELOPMENT SCHEME FOR INFORMATION - RUNS ONLY ON A DEVELOPMENT SCHEME");
    DVLog_HIGHLIGHT(@"<* DVLog_HIGHLIGHT *> LOGGER FOR A DEVELOPMENT SCHEME FOR HIGHLIGHT - RUNS ONLY ON A DEVELOPMENT SCHEME");
    DVLog_WARNING(@"<* DVLog_WARNING *> LOGGER FOR A DEVELOPMENT SCHEME FOR WARNINGS - RUNS ONLY ON A DEVELOPMENT SCHEME");
    DVLog_ERROR(@"<* DVLog_ERROR *> LOGGER FOR A DEVELOPMENT SCHEME FOR ERRORS - RUNS ONLY ON A DEVELOPMENT SCHEME");
    
    
    
    //DDLog - it's automatically used with both debug and development schemes. No manual linking required.
    //It's useful for having a shared output between both schemes but striped away when releasing the app.
    DDLog_NH(@"\n\n-------------------------------------DDLog-------------------------------------------------");
    DDLog_NH(@"It's automatically used with both Debug and Development schemes. No manual linking required.\n\n");
    
    DDLog(@"<* DDLog *> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES");
    DDLog_NH(@"<* DDLog_NH *> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES WITHOUT HEADER");
    DDLog_INFO(@"<* DDLog_INFO *> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR INFORMATION");
    DDLog_HIGHLIGHT(@"<* DDLog_HIGHLIGHT *> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR HIGHLIGHT ");
    DDLog_WARNING(@"<* DDLog_WARNING *> SHARED LOGGER DEBUG & DEVELOPMENT SCHEMES FOR WARNINGS");
    DDLog_ERROR(@"<* DDLog_ERROR *> SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR ERRORS");
    
    
    //OLog - should be linked with a scheme that's debugging online services
    OLog_NH(@"\n\n-------------------------------------OLog--------------------------------------------------");
    OLog_NH(@"--------------Should be linked with a scheme that's debugging online services--------------\n\n");
    
    OLog(@"<* OLog *> ");
    OLog_NH(@"<* OLog_NH *> ");
    OLog_INFO(@"<* OLog_INFO *> ");
    OLog_HIGHLIGHT(@"<* OLog_HIGHLIGHT *> ");
    OLog_WARNING(@"<* OLog_WARNING *> ");
    OLog_ERROR(@"<* OLog_ERROR *> ");
    
    
    //Performance Tests (if you have CocoaLumberjack,
    //uncomment ENABLE_COCOALUMBERJACK macro in XLPerformanceTests.h)
    //    [XLPerformanceTests startPerformanceTestWithNumberOfRuns:5
    //                                          numberOfIterations:1000];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
