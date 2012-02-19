//
//  PMViewController.h
//  TestApp
//
//  Created by Demo on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PMViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate, UIWebViewDelegate>
@property (strong, nonatomic, readwrite) UIWebView *webView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKUserLocation *userLocation;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (strong, nonatomic) NSMutableData *mutableData; 
@property (weak, nonatomic) IBOutlet UILabel *dangerLabel;
@property (strong, nonatomic) NSMutableArray *friendLoc;

- (IBAction)findFriendsButtonTouched:(id)sender;
-(void)loadPins: (NSString *)token ;
@end
