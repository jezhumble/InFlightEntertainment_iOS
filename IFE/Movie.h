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

@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSURL *imdbWebLink;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) int runtime;
@property (nonatomic, assign) NSString *genre;

@end
