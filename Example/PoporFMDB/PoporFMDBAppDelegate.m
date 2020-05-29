//
//  PoporFMDBAppDelegate.m
//  PoporFMDB
//
//  Created by wangkq on 07/03/2018.
//  Copyright (c) 2018 wangkq. All rights reserved.
//

#import "PoporFMDBAppDelegate.h"

@implementation PoporFMDBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * iosInjectionPath = @"/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle";
    if ([[NSFileManager defaultManager] fileExistsAtPath:iosInjectionPath]) {
        [[NSBundle bundleWithPath:iosInjectionPath] load];
    }
#endif

    return YES;
}

@end
