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
    
    // Required for iOS Projects to enable the Xcode Colors plugin.
    // If the plugin is not installed, the output will contain the colors escape strings.
    // If the plugin is installed but not loaded, either update the plugin
    // to the newest version containing the latest Xcode's UDID or do it
    // yourself: https://github.com/robbiehanson/XcodeColors/wiki/XcodeUpdates
    
    // If you encounter any issues with Xcode Colors, comment the line below.
    setenv("XcodeColors", "YES", 0);
    
    //grab a reference to Xcode Logger singleton instance
    XcodeLogger *xManager = [XcodeLogger sharedManager];
    
    //check Info.plist to see why
    [xManager setInfoPlistKeyNameForRunningSchemes:@"XLRunningScheme"];
    
    //scheme linking - case insensitive
    [xManager setBuildSchemeName:@"xl debug"
                     forXLogType:XLOGGER_TYPE_DEBUG];
    
    //[xManager setBuildSchemeName:@"xl development"
    //                 forXLogType:XLOGGER_TYPE_DEVELOPMENT];
    
    [xManager setBuildSchemeName:@"xl online"
                     forXLogType:XLOGGER_TYPE_ONLINE_SERVICES];
    
    
    
    //XLog - the 1:1 replacement for NSLog
    XLog_NH(@"--------------------------------------XLog--------------------------------------------------");
    
    XLog(@"SIMPLE NSLog REPLACEMENT WITH HEADER - RUNS INDEPENDENTLY OF CURRENT SCHEMA");
    XLog_NH(@"SIMPLE NSLog REPLACEMENT WITHOUT HEADER - RUNS INDEPENDENTLY OF CURRENT SCHEMA");
    XLog_INFO(@"SIMPLE NSLog REPLACEMENT FOR INFORMATION - RUNS INDEPENDENTLY OF CURRENT SCHEMA");
    XLog_HIGHLIGHT(@"SIMPLE NSLog REPLACEMENT FOR HIGHLIGHT - RUNS INDEPENDENTLY OF CURRENT SCHEMA");
    XLog_WARNING(@"SIMPLE NSLog REPLACEMENT FOR WARNINGS - RUNS INDEPENDENTLY OF CURRENT SCHEMA");
    XLog_ERROR(@"SIMPLE NSLog REPLACEMENT FOR ERRORS - RUNS INDEPENDENTLY OF CURRENT SCHEMA");
    
    //DLog - should be linked with a debug scheme
    DLog_NH(@"--------------------------------------DLog--------------------------------------------------");
    
    DLog(@"LOGGER FOR A DEBUG SCHEMA - RUNS ONLY ON A DEBUG SCHEMA");
    DLog_NH(@"LOGGER FOR A DEBUG SCHEMA WITHOUT HEADER - RUNS ONLY ON A DEBUG SCHEMA");
    DLog_INFO(@"LOGGER FOR A DEBUG SCHEMA FOR INFORMATION - RUNS ONLY ON A DEBUG SCHEMA");
    DLog_HIGHLIGHT(@"LOGGER FOR A DEBUG SCHEMA FOR HIGHLIGHT - RUNS ONLY ON A DEBUG SCHEMA");
    DLog_WARNING(@"LOGGER FOR A DEBUG SCHEMA FOR WARNINGS - RUNS ONLY ON A DEBUG SCHEMA");
    DLog_ERROR(@"LOGGER FOR A DEBUG SCHEMA FOR ERRORS - RUNS ONLY ON A DEBUG SCHEMA");
    
    //DVLog - should be linked with a development scheme
    DVLog_NH(@"-------------------------------------DVLog-------------------------------------------------");
    
    DVLog(@"LOGGER FOR A DEVELOPMENT SCHEMA - RUNS ONLY ON A DEVELOPMENT SCHEMA");
    DVLog_NH(@"LOGGER FOR A DEVELOPMENT SCHEMA WITHOUT HEADER - RUNS ONLY ON A DEVELOPMENT SCHEMA");
    DVLog_INFO(@"LOGGER FOR A DEVELOPMENT SCHEMA FOR INFORMATION - RUNS ONLY ON A DEVELOPMENT SCHEMA");
    DVLog_HIGHLIGHT(@"LOGGER FOR A DEVELOPMENT SCHEMA FOR HIGHLIGHT - RUNS ONLY ON A DEVELOPMENT SCHEMA");
    DVLog_WARNING(@"LOGGER FOR A DEVELOPMENT SCHEMA FOR WARNINGS - RUNS ONLY ON A DEVELOPMENT SCHEMA");
    DVLog_ERROR(@"LOGGER FOR A DEVELOPMENT SCHEMA FOR ERRORS - RUNS ONLY ON A DEVELOPMENT SCHEMA");
    
    //DDLog - it's automatically used with both debug and development schemes. No manual linking required.
    DDLog_NH(@"-------------------------------------DDLog-------------------------------------------------");
    
    DDLog(@"SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES");
    DDLog_NH(@"SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES WITHOUT HEADER");
    DDLog_INFO(@"SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR INFORMATION");
    DDLog_HIGHLIGHT(@"SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR HIGHLIGHT ");
    DDLog_WARNING(@"SHARED LOGGER DEBUG & DEVELOPMENT SCHEMES FOR WARNINGS");
    DDLog_ERROR(@"SHARED LOGGER FOR DEBUG & DEVELOPMENT SCHEMES FOR ERRORS");
    
    OLog_NH(@"-------------------------------------OLog--------------------------------------------------");
    
    //OLog - should be linked with a scheme that's debugging online services
    OLog(@"OLOG");
    OLog_NH(@"OLOG_NH");
    OLog_INFO(@"OLOG_INFO");
    OLog_HIGHLIGHT(@"OLOG_HIGHLIGHT");
    OLog_WARNING(@"OLOG_WARNING");
    OLog_ERROR(@"OLOG_ERROR");
    
    
    //let's make some performance tests
    [XLPerformanceTests startPerformanceTestWithNumberOfRuns:5
                                          numberOfIterations:5000];
    
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
