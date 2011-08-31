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

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>

#pragma mark IFEAppDelegate () 

// forward declarations
@interface IFEAppDelegate ()

@property (nonatomic, retain) NSURLConnection *IFEFeedConnection;
@property (nonatomic, retain) NSMutableData *IFEData;    // the data returned from the NSURLConnection
@property (nonatomic, retain) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing earthquake data

- (void)handleError:(NSError *)error;
- (void)addMoviesToList:(NSArray *)movies;
@end

@implementation IFEAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize rootViewController = _rootViewController;
@synthesize IFEFeedConnection;
@synthesize IFEData;
@synthesize parseQueue;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the navigation controller's view to the window and display.
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not
    // be blocked - the application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked!
    // Also, avoid synchronous network access on any thread.
    //
    static NSString *feedURLString = @"http://jezhumble.net/ife.xml";
    NSURLRequest *IFEURLRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.IFEFeedConnection =
    [[[NSURLConnection alloc] initWithRequest:IFEURLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development.
    // If the URL is more dynamic, then you should implement a more flexible validation technique,
    // and be able to both recover from errors and communicate problems to the user in an
    // unobtrusive manner.
    NSAssert(self.IFEFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection
    // finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addIFE:)
                                                 name:kAddIFENotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFEError:)
                                                 name:kIFEErrorNotif
                                               object:nil];
    
    
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
    [IFEFeedConnection cancel];
    [IFEFeedConnection release];
    
    [IFEData release];
    [_window release];
    [_navigationController release];
    [_rootViewController release];

    [parseQueue release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddIFENotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kIFEErrorNotif object:nil];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2)) {
        self.IFEData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [IFEData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"Error message displayed when not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.IFEFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.IFEFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithData:self.IFEData];
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   // once added to the NSOperationQueue it's retained, we don't need it anymore
    
    // earthquakeData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.IFEData = nil;
}


// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)IFEError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kIFEMsgErrorKey]];
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
