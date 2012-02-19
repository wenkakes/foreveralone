//
//  NSDate.m
//  TestApp
//
//  Created by hoppers on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Formatting.h"

@implementation NSDate (Formatting)

- (NSString*) timeAgoInWords {
    double seconds = [self timeIntervalSinceNow];
    seconds = seconds * -1;
    
    if (seconds < 1 ) {
        return @"now";
    } else if (seconds < 60) {
        return @"less than a minute ago";
    } else if (seconds > 604800) {
        return @"too long ago";
    } else {
        NSUInteger difference = 0;
        BOOL pluralize = NO;
        NSString* unit = @"";
        
        if (seconds < 3600) {
            difference = round(seconds / 60);
            unit = @"minute";
        } else if (seconds < 86400) {
            difference = round(seconds / 3600);
            unit = @"hour";
        } else {
            difference = round(seconds / 86400);
            unit = @"day";
        }
        
        if (difference > 1) {
            pluralize = YES;
        }
        
        return [NSString stringWithFormat:@"%d %@%@ ago", difference, unit, (pluralize ? @"s" : @"")];
    }
}

@end
