//
//  IFEAppDelegate.h
//  IFE
//
//  Created by Jez Humble on 8/29/11.
//  Copyright 2011 Jez Humble. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Movie, RootViewController;

@interface IFEAppDelegate : NSObject <UIApplicationDelegate, NSXMLParserDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    RootViewController *rootViewController;

@private
    // for downloading the xml data
    NSURLConnection *IFEFeedConnection;
    NSMutableData *IFEData;
    
    NSOperationQueue *parseQueue;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@end
