//
//  ParseOperation.h
//  InFlightEntertainment
//
//  Created by Jez Humble on 8/28/11.
//  Copyright 2011 Jez Humble. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *kAddIFENotif;
extern NSString *kIFEResultsKey;

extern NSString *kIFEErrorNotif;
extern NSString *kIFEMsgErrorKey;

@class Movie;

@interface ParseOperation : NSOperation {
    NSData *IFEData;
    
    @private
    NSMutableArray *currentParseBatch;
    NSMutableString *currentParsedCharacterData;
    
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedIFECounter;
}

@property (copy, readonly) NSData *IFEData;

@end
