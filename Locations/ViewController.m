//
//  ViewController.m
//  Locations
//
//  Created by Jay Versluis on 10/01/2014.
//  Copyright (c) 2014 Pinkstone Pictures LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *longLabel;
@property (strong, nonatomic) IBOutlet UILabel *latLabel;
@property (strong, nonatomic) IBOutlet UILabel *accuracyLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self startLocations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLocations {
    
    // create and start the location manager
    CLLocationManager *manager = [[CLLocationManager alloc]init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
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
    
}

@end
