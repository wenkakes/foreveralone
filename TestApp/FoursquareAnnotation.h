//
//  FoursquareAnnotation.h
//  TestApp
//
//  Created by Demo on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>

@interface FoursquareAnnotation : UIView <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property BOOL isPerson;
@property (nonatomic, strong) UIImage *image;

@end
