//
//  AppDelegate.m
//  VK simple client
//
//  Created by Виктор Стариков on 06.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayController.h"
#import "VKLoginViewController.h"
#import "MyMusicTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate () 

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [VKSdk initializeWithDelegate:nil andAppId:@"4717791"];
    
    if ([VKSdk wakeUpSession]) {
        UINavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"mainNavigation"];
        self.window.rootViewController = controller;
    } else {
        VKLoginViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"loginController"];
        self.window.rootViewController = controller;
    }
    
    [self.window makeKeyAndVisible];
    
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
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[PlayController sharedInstance] togglePlayPause];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [[PlayController sharedInstance] play];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [[PlayController sharedInstance] pause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[PlayController sharedInstance] playPreviousTrack];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [[PlayController sharedInstance] playNextTrack];
                break;
                
            default:
                break;
        }
    }
}

@end
