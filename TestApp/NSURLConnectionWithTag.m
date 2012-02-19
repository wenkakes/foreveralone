//
//  NSURLConnectionWithTag.m
//  TestApp
//
//  Created by hoppers on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSURLConnectionWithTag.h"
#import "Reachability.h"

@implementation NSURLConnectionWithTag

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSNumber*)_tag {
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        
        // Always do some reachability handling
        
        return nil;
    }
    
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    
    if (self) {
        self.tag = _tag;
    }
    
    return self;
    
}

@end
