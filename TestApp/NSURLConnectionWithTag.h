//
//  NSURLConnectionWithTag.h
//  TestApp
//
//  Created by hoppers on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnectionWithTag : NSURLConnection {
    
    NSNumber *tag;
    
}
@property (nonatomic, retain) NSNumber *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSNumber*)_tag;

@end