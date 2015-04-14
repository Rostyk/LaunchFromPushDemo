//
//  AppDelegate.m
//  LaunchFromPushStatstic
//
//  Created by Rostyslav.Stepanyak on 4/10/15.
//  Copyright (c) 2015 Rostyslav.Stepanyak. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIEcommerceProduct.h"
#import "GAIEcommerceProductAction.h"
#import "GAIEcommercePromotion.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"
#import "GAITracker.h"


#define GA_TRACKER_ID                @"UA-55705032-4"

@interface AppDelegate ()
@property (nonatomic, strong) id<GAITracker> tracker;
@property (nonatomic) BOOL sentFromDidFinishLaunching;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupParse:application];
    [self setupGoogleAnalitics];
    
    if (launchOptions != nil) {
        NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if(notification) {
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ios_app_launched_from_push"
                                                                       action:@"the_app_was_not_running"
                                                                        label:@""
                                                                        value:nil] build]];
            self.sentFromDidFinishLaunching = YES;
        }
    }
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        /*In case the event has already been sent from didFinishLaunching we need to skip this.
         The app was launched for the first time, (previously the user force quit it) it was not in the background*/
        if(!self.sentFromDidFinishLaunching)
           [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ios_app_launched_from_push"
                                                                   action:@"from_background"
                                                                    label:@""
                                                                    value:nil] build]];
        
        self.sentFromDidFinishLaunching = NO;
    }
    else {
        //The app is in the foreground
    }
    
    [PFPush handlePush:userInfo];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    }

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark Parse

- (void)setupParse:(UIApplication *)application {
    [Parse setApplicationId:@"bfWHqXF8yImxY74eTlOTqQdP0OI7NLY8ULuj7doX"
                  clientKey:@"gM5ZWAEhTQK5zHF4M7SohYvPpzqyFWbRZKah6ods"];

    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void)setupGoogleAnalitics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKER_ID];
}

@end
