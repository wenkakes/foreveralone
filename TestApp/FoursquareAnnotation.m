//
//  FoursquareAnnotation.m
//  TestApp
//
//  Created by Demo on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoursquareAnnotation.h"

@implementation FoursquareAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize isPerson;
@synthesize image;

- (id) initWithFrame:(CGRect)frame {
    
    // Initialise the frame
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialise stuff
    }
    return self;
}

@end
