//
//  ViewController.m
//  Locations
//
//  Created by Jay Versluis on 10/01/2014.
//  Copyright (c) 2014 Pinkstone Pictures LLC. All rights reserved.
//

#import "ViewController.h"
#import "Pin.h"

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) IBOutlet UILabel *longLabel;
@property (strong, nonatomic) IBOutlet UILabel *latLabel;
@property (strong, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self startLocations];
    
    // add a long press gesture
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addPin:)];
    recognizer.minimumPressDuration = 0.5;
    [self.mapView addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Location Manager

- (CLLocationManager *)manager {
    
    if (!_manager) {
        _manager = [[CLLocationManager alloc]init];
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _manager;
}

- (MKMapView *)mapView {
    
    if (!_mapView) {
        _mapView = [[MKMapView alloc]init];
        
        // add a long press gesture
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addPin:)];
        recognizer.minimumPressDuration = 0.5;
        [_mapView addGestureRecognizer:recognizer];

    }
    return _mapView;
}

- (void)startLocations {
    
    // create and start the location manager
    
    [self.manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yellow"]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    
    // grab current location and display it in a label
    CLLocation *currentLocation = [locations lastObject];
    
    NSString *longText = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    NSString *latText = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    NSString *accuracy = [NSString stringWithFormat:@"%f", currentLocation.horizontalAccuracy];
    
    self.longLabel.text = longText;
    self.latLabel.text = latText;
    self.accuracyLabel.text = accuracy;
    
    // and update our Map View
    [self updateMapView:currentLocation];
}

#pragma mark - Map Kit

- (void)updateMapView:(CLLocation *)location {
    
    // create a region and pass it to the Map View
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.latitudeDelta = 0.001;
    region.span.longitudeDelta = 0.001;
    
    [self.mapView setRegion:region animated:YES];
    
    // remove previous marker
    MKPlacemark *previousMarker = [self.mapView.annotations lastObject];
    [self.mapView removeAnnotation:previousMarker];
    
    // create a new marker in the middle
    MKPlacemark *marker = [[MKPlacemark alloc]initWithCoordinate:location.coordinate addressDictionary:nil];
    [self.mapView addAnnotation:marker];
    
    // create an address from our coordinates
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks lastObject];
        NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@", placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
        if (placemark.thoroughfare != NULL) {
            self.addressLabel.text = address;
        } else {
            self.addressLabel.text = @"";
        }

    }];
}

// let the user add their own pins

- (void)addPin:(UIGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // convert touched position to map coordinate
    CGPoint userTouch = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D mapPoint = [self.mapView convertPoint:userTouch toCoordinateFromView:self.mapView];
    
    // and add it to our view
    Pin *newPin = [[Pin alloc]init];
    newPin.coordinate = mapPoint;
    [self.mapView addAnnotation:newPin];
    
    // for a laugh: access all annotations and print them
    NSArray *allPins = self.mapView.annotations;
    int i = 1;
    for (Pin *thisPin in allPins) {
        NSLog(@"Pin No. %i: %f, %f", i, thisPin.coordinate.latitude, thisPin.coordinate.longitude);
        i++;
    }
    
}

@end
