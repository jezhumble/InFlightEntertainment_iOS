//
//  RootViewController.h
//  IFE
//
//  Created by Jez Humble on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
    NSMutableArray *IFEList;
}

@property (nonatomic, retain) NSMutableArray *IFEList;

- (void)insertMovies:(NSArray *)movies;   // addition method of movies (for KVO purposes)

@end
