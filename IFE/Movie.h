//
//  Movie.h
//  InFlightEntertainment
//
//  Created by Jez Humble on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject {
    NSString *name;
    NSURL *imdbWebLink;
    CGFloat rating;
    int runtime;
    NSString *genre; 
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSURL *imdbWebLink;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) int runtime;
@property (nonatomic, retain) NSString *genre;

@end
