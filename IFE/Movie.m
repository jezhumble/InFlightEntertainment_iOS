//
//  Movie.m
//  InFlightEntertainment
//
//  Created by Jez Humble on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize name;
@synthesize imdbWebLink;
@synthesize rating;
@synthesize year;
@synthesize runtime;
@synthesize genre;


- (void)dealloc {
    [name release];
    [imdbWebLink release];
    [genre release];
    [super dealloc];
}

@end
