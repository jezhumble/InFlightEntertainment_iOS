//
//  ParseOperation.m
//  InFlightEntertainment
//
//  Created by Jez Humble on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParseOperation.h"
#import "Movie.h"

// NSNotification name for sending earthquake data back to the app delegate
NSString *kAddIFENotif = @"AddIFENotif";

// NSNotification userInfo key for obtaining the earthquake data
NSString *kIFEResultsKey = @"IFEResultsKey";

// NSNotification name for reporting errors
NSString *kIFEErrorNotif = @"IFEErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kIFEMsgErrorKey = @"IFEMsgErrorKey";

@interface ParseOperation () <NSXMLParserDelegate>
    @property (nonatomic, retain) Movie *currentMovieObject;
    @property (nonatomic, retain) NSMutableArray *currentParseBatch;
    @property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@end

@implementation ParseOperation

@synthesize IFEData, currentMovieObject, currentParsedCharacterData, currentParseBatch;

- (id)initWithData:(NSData *)parseData
{
    if (self = [super init]) {    
        IFEData = [parseData copy];
    }
    return self;
}

- (void)addMoviesToList:(NSArray *)movies {
    assert([NSThread isMainThread]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddIFENotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:movies
                                                                                           forKey:kIFEResultsKey]]; 
}

- (void)main {
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.IFEData];
    [parser setDelegate:self];
    [parser parse];
    
    // depending on the total number of earthquakes parsed, the last batch might not have been a
    // "full" batch, and thus not been part of the regular batch transfer. So, we check the count of
    // the array and, if necessary, send it to the main thread.
    //
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addMoviesToList:)
                               withObject:self.currentParseBatch
                            waitUntilDone:NO];
    }
    
    self.currentParseBatch = nil;
    self.currentMovieObject = nil;
    self.currentParsedCharacterData = nil;
    
    [parser release];
}

- (void)dealloc {
    [IFEData release];
    
    [currentMovieObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    // If the number of parsed earthquakes is greater than
    // kMaximumNumberOfEarthquakesToParse, abort the parse.
    //
    if ([elementName isEqualToString:@"movie"]) {
        Movie *movie = [[Movie alloc] init];
        self.currentMovieObject = movie;
        [movie release];
        NSString *movieName = [attributeDict objectForKey:@"name"];
        if (movieName) {
            self.currentMovieObject.name = movieName;
        }
        NSString *genre = [attributeDict objectForKey:@"genre"];
        if (genre) {
            self.currentMovieObject.genre = genre;
        }
        NSString *runtime = [attributeDict objectForKey:@"runtime"];
        if (runtime) {
            self.currentMovieObject.runtime = [runtime intValue];
        }
        NSString *year = [attributeDict objectForKey:@"year"];
        if (year) {
            self.currentMovieObject.year = [year intValue];
        }
        NSString *rating = [attributeDict objectForKey:@"rating"];
        if (runtime) {
            self.currentMovieObject.rating = [rating floatValue];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:@"movie"]) {
        [self.currentParseBatch addObject:self.currentMovieObject];
        parsedIFECounter++;
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
    }
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
}

// an error occurred while parsing the earthquake data,
// post the error as an NSNotification to our app delegate.
// 
- (void)handleIFEError:(NSError *)parseError {
    [[NSNotificationCenter defaultCenter] postNotificationName:kIFEErrorNotif
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                           forKey:kIFEMsgErrorKey]];
}

// an error occurred while parsing the earthquake data,
// pass the error to the main thread for handling.
// (note: don't report an error if we aborted the parse due to a max limit of earthquakes)
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handleIFEError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}


@end
