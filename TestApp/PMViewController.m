//
//  PMViewController.m
//  TestApp
//
//  Created by Demo on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PMViewController.h"
#import "SBJson.h"
#import "FoursquareAnnotation.h"
#import "PMAunthController.h"
#import <CoreLocation/CoreLocation.h>
#import "NSURLConnectionWithTag.h"
#import <CoreGraphics/CoreGraphics.h>
#import "NSDate+Formatting.h"

@interface PMViewController ()

@end

@implementation PMViewController

@synthesize webView = _webView;
@synthesize mapView;
@synthesize userLocation;
@synthesize urlConnection;
@synthesize mutableData;
@synthesize dangerLabel;
@synthesize friendLoc;

CLLocationCoordinate2D ownLoc;

bool signedIn = NO;
bool dangerous = NO;
NSString *token; 
NSMutableDictionary *dataFromConnectionsByTag;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (dataFromConnectionsByTag == nil) {
        dataFromConnectionsByTag = [[NSMutableDictionary alloc] init];
        
    }
    
    friendLoc = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setWebView:nil];
    [self setDangerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)connection:(NSURLConnectionWithTag *)connection didReceiveData:(NSData *)data{
    
    if ([dataFromConnectionsByTag objectForKey:connection.tag] == nil) {
        
        NSMutableData *newData = [[NSMutableData alloc] initWithData:data];
        
        [dataFromConnectionsByTag setObject:newData forKey:connection.tag];
        
        return;
        
    } else {
        
        [[dataFromConnectionsByTag objectForKey:connection.tag] appendData:data];
        
    }
    
}

- (void)mapView:(MKMapView *)mapViewIn didUpdateUserLocation:(MKUserLocation *)userLocationIn {
    
    // Manual Override
 //   CLLocationCoordinate2D userLoc;
 //   userLoc.latitude = 55.944754;
 //   userLoc.longitude = -3.186936;
    
 //   MKCoordinateRegion region = {{ userLoc.latitude, userLoc.longitude }, {0.009f, 0.009f}};
    
    
    CLLocationCoordinate2D userLoc = [userLocationIn coordinate];
    MKCoordinateRegion region = {{ userLoc.latitude, userLoc.longitude }, {0.009f, 0.009f}};
    [mapViewIn setRegion: region animated: YES];
    ownLoc = userLoc;
}

-(void)loadPins:(NSString *)token {
    
    if (signedIn) {
        NSLog(@"signed in!");
        [self setMutableData:nil];
        [ self.mapView removeAnnotations:[ self.mapView annotations]];
        
        NSString *urlRequestString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/checkins/recent?oauth_token=%@", token];
        
        NSURL *urlRequestURL = [NSURL URLWithString: urlRequestString];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL: urlRequestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval: 30.f];
        
        self.urlConnection = [[NSURLConnectionWithTag alloc] initWithRequest:urlRequest delegate:self startImmediately:YES tag:[NSNumber numberWithInt:1]];
        
    } else {
        NSLog(@"not signed in yet");
    }
}

-(void)loadVenues {
    
    if (signedIn) {
        NSLog(@"signed in!");
        [self setMutableData:nil];
        [ self.mapView removeAnnotations:[ self.mapView annotations]];
        
        NSString *urlRequestString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=OP4KNPDFZPAQQMOF5WUZGFWKIMOFM5WNFMMQXYOAE4SBL4LI&client_secret=ITEFCNFJXDM05EJRQYEZMW32OOVOONATD3TUAOQTHP1MZLGG&query=food", [[mapView userLocation ]coordinate].latitude, [[mapView userLocation] coordinate].longitude,2000]; 
        
        NSURL *urlRequestURL = [NSURL URLWithString: urlRequestString];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL: urlRequestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval: 30.f];
        
        self.urlConnection = [[NSURLConnectionWithTag alloc] initWithRequest:urlRequest delegate:self startImmediately:YES tag:[NSNumber numberWithInt:2]];
        
    } else {
        NSLog(@"not signed in yet");
    }
}

-(void)connectionDidFinishLoading:(NSURLConnectionWithTag *)connection {
    


    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSString *stringContainingMutableData = [[NSString alloc] initWithData:[dataFromConnectionsByTag objectForKey:connection.tag] encoding:NSUTF8StringEncoding];
    // Parse the object and store it as an NSDictionary object
    // NSLog(@"%@", stringContainingMutableData);
    NSError *error = nil;
    NSDictionary *dictionaryListing = [jsonParser objectWithString: stringContainingMutableData error:&error];
    if (error)
    {
        NSLog(@": error parsing mutable data = %@", [error localizedDescription]);
    }
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    if ([connection.tag intValue] == 1) {                   // Fetch the users who aren't yourself

        [self.friendLoc removeAllObjects];    
        NSDictionary *itemsInDictionary = [[dictionaryListing objectForKey:@"response"] objectForKey:@"recent"];
        
        int dangerN = 0;
        NSString *dangerNames = @"";
        
        for (NSDictionary *update in itemsInDictionary) {
            
            NSString *rs = [[ update objectForKey:@"user"] objectForKey:@"relationship"];
            
            if (![rs isEqualToString:@"self"]) {
                
                NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[update objectForKey:@"createdAt"] doubleValue]];
                NSString *firstName = [[ update objectForKey:@"user" ] objectForKey:@"firstName"];
                NSString *lastName = [[update objectForKey:@"user"] objectForKey:@"lastName"];
                NSString *photoURLString = [[update objectForKey:@"user"] objectForKey:@"photo"];
                NSString *venueName = [[update objectForKey:@"venue"] objectForKey: @"name"];
                NSString *venueAdd = [[[update objectForKey:@"venue"] objectForKey:@"location"] objectForKey: @"address"];
                CGFloat lat = [[[[update objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
                CGFloat lng = [[[[update objectForKey:@"venue"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
                
                NSURL *photoURL = [NSURL URLWithString:photoURLString];
                NSData *imageData = [NSData dataWithContentsOfURL:photoURL];
                UIImage *photoImage = [UIImage imageWithData:imageData];
                
                FoursquareAnnotation *fsqAnnotation = [[FoursquareAnnotation alloc] init];
                MKCoordinateRegion r = { { lat, lng }, {0.01f, 0.01f } };
                
                // Check if they are a safe distance away
                CLLocation *friendLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:ownLoc.latitude longitude:ownLoc.longitude];
                double distanceToFriend = [friendLocation distanceFromLocation:myLocation];
                
                NSString *safeOrNotString = @"";
                if (distanceToFriend < 200) {
                    safeOrNotString = @"DANGER";
                    
                    if (!dangerN) dangerNames = [NSString stringWithFormat: @"Too close to %@ %@", firstName, lastName];
                    dangerN++;
                    dangerous = YES;
                    
                } else {
                    safeOrNotString = @"SAFE";
                    dangerous = NO;
                }
                NSString *timesinceString = timestamp.timeAgoInWords;
                NSString *titleString = [NSString stringWithFormat: @"%@ from %@ %@", safeOrNotString, firstName, lastName];
                NSString *subtitleString = [NSString stringWithFormat: @"Last seen %@ at %@, %@", timesinceString, venueName, venueAdd];
                
                [fsqAnnotation setCoordinate:r.center];
                [fsqAnnotation setTitle: titleString ]; 
                [fsqAnnotation setSubtitle:subtitleString];
                [fsqAnnotation setIsPerson:YES];
                [fsqAnnotation setImage:photoImage];
                //   [fsqAnnotation setI
                [annotations addObject:fsqAnnotation];
                

                [friendLoc addObject:friendLocation];
                
                [dataFromConnectionsByTag removeAllObjects];
            }
        }
        
        [mapView addAnnotations:annotations];
        [self setMutableData: nil];
        
        if (dangerN > 1) dangerNames = [NSString stringWithFormat: @"%@ and %d others", dangerNames, dangerN - 1];
        
        dangerNames = [NSString stringWithFormat:@"%@. Do you want to find a new place?", dangerNames];
        
        if (dangerN) {
            // Add popup alert here.
            UIAlertView *dangerAlert = [[UIAlertView alloc] initWithTitle:@"DANGER" message:dangerNames delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            
            [dangerAlert show];
        } else {
            self.dangerLabel.hidden = YES;
            UIAlertView *noDangerAlert = [[UIAlertView alloc] initWithTitle:@"NO DANGER" message:@"Safe... for now." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [noDangerAlert show];
        }
    } else {                // Fetch nearby venues that are far away from other people
            
        NSLog(@"Make venues show up.");

        NSDictionary *itemsInDictionary = [[[[dictionaryListing objectForKey: @"response"] objectForKey: @"groups"] objectAtIndex: 0] objectForKey: @"items"];
        
        bool foundCandidate = NO;
        for (NSDictionary *venue in itemsInDictionary) {
            
            NSString *name = [venue objectForKey:@"name"];
            //NSString *type = [[[venue objectForKey:@"categories"] objectAtIndex: 0] objectForKey:@"name"];
            CGFloat lat = [[[venue objectForKey:@"location"] objectForKey:@"lat"] floatValue];
            CGFloat lng = [[[venue objectForKey:@"location"] objectForKey:@"lng"] floatValue];
            
            FoursquareAnnotation *fsqAnnotation = [[FoursquareAnnotation alloc] init];
            MKCoordinateRegion r = { { lat, lng }, {0.1f, 0.1f } };
            
            double newDistanceToFriend = 0;
            bool currCandidate = YES;
            for (CLLocation *friend in friendLoc) {
                // Check if they are a safe distance away
                CLLocation *candidateLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
                newDistanceToFriend = [friend distanceFromLocation:candidateLocation];
           
                if (newDistanceToFriend < 200) {
                    currCandidate = NO;
                    break;
                }
            }
            if (currCandidate) {
                NSString *titleString = [NSString stringWithFormat: @"%@", name];
                NSString *subtitleString = [NSString stringWithFormat: @"It's safe."];
                
                [fsqAnnotation setCoordinate:r.center];
                [fsqAnnotation setTitle: titleString ]; 
                [fsqAnnotation setSubtitle:subtitleString];
                [fsqAnnotation setIsPerson:NO];
                [annotations addObject:fsqAnnotation];
                foundCandidate = YES;
            }                
                       
        }
        
        [mapView addAnnotations:annotations];
        [self setMutableData: nil];

        if (!foundCandidate) {    // Add popup alert here.
           UIAlertView *dangerAlert = [[UIAlertView alloc] initWithTitle:@"NOWHERE SAFE NEARBY" message:@"We just have to hope for the best now..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [dangerAlert show];
        }
        
        
    }
    
    
    [dataFromConnectionsByTag removeAllObjects];
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {
        NSLog(@"ok - find a new place");
        [self loadVenues];
    }
    else
    {
        NSLog(@"cancel");
        if (!dangerous) self.dangerLabel.hidden = YES;
        else self.dangerLabel.hidden = NO;
    }
}

- (IBAction)findFriendsButtonTouched:(id)sender {
    self.dangerLabel.hidden = YES;
    
    self.webView = [[UIWebView alloc ] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    NSString *authenticateURLString = [NSString stringWithFormat:@"https://foursquare.com/oauth2/authenticate?client_id=OP4KNPDFZPAQQMOF5WUZGFWKIMOFM5WNFMMQXYOAE4SBL4LI&response_type=token&redirect_uri=http://stevenskelton.co.uk"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
}

#pragma mark - UIWebView delegate methods 
-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"Web view started loading...");
}
-(void)webViewDidFinishLoad:(UIWebView *) webView {
    NSString *URLString = [[self.webView.request URL] absoluteString];
    
    if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:@"access_token"];
        [defaults synchronize];
        self.webView.hidden = YES;
        signedIn = YES;
        [self loadPins:accessToken]; 

    }
}

-(UIImage*)imageWithBorderFromImage:(UIImage*)source {
    CGSize size = [source size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0,0,size.width, size.height);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextStrokeRect(context,rect);
    UIImage *testImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

-(MKAnnotationView *) mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation> ) annotation {
 //   if (annotation == mapViewIn.userLocation) { return nil; };

    if ([annotation isKindOfClass:[FoursquareAnnotation class]]) {
        FoursquareAnnotation *a = (FoursquareAnnotation *) annotation;
       
        static NSString *identifier = @"FoursquareAnnotation";
        MKAnnotationView *annotationView = (MKAnnotationView*) [mapViewIn dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!annotationView) {
           // NSLog(@"annotation view created for %@.", a);
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        
        
        if (a.isPerson) {
            UIImage *resizedImage = [UIImage imageWithCGImage:[a.image CGImage] scale:3.0 orientation:UIImageOrientationUp];
            UIImage *borderImage = [self imageWithBorderFromImage: resizedImage];
            //UIImageView *imageView = [[UIImageView alloc] initWithImage:borderImage];
            [annotationView setEnabled:YES];
            [annotationView setImage:borderImage];
            [annotationView setCanShowCallout:YES];
            
            
            return annotationView;
        } 
    }
    //NSLog(@"not foursquare");
    return nil;
}

@end
