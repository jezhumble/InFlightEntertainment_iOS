//
//  IFEAppDelegate.m
//  IFE
//
//  Created by Jez Humble on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IFEAppDelegate.h"
#import "RootViewController.h"
#import "ParseOperation.h"
#import "Movie.h"

#pragma mark IFEAppDelegate () 

// forward declarations
@interface IFEAppDelegate ()

- (void)addMoviesToList:(NSArray *)movies;
@end

@implementation IFEAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize rootViewController = _rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
//    [window addSubview:navigationController.view];
    
    [self.window makeKeyAndVisible];
    
    NSMutableArray *movies = [[NSMutableArray alloc] init];
    Movie *movie = [[Movie alloc] init];
    [movie setName:@"Test"];
    [movie setRuntime:120];
    [movie setGenre:@"Action"];
    [movie setRating:7.8f];
    [movies addObject:movie];
    
    [self addMoviesToList:movies];
    [movie release];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (void)addIFE:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self addMoviesToList:[[notif userInfo] valueForKey:kIFEResultsKey]];
}

- (void)addMoviesToList:(NSArray *)movies {
    
    // insert the earthquakes into our rootViewController's data source (for KVO purposes)
    [self.rootViewController insertMovies:movies];
}

@end
