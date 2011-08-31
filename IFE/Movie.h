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
    NSInteger runtime;
    NSInteger year;
    NSString *genre; 
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *imdbWebLink;
@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) NSInteger runtime;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, copy) NSString *genre;

@end
