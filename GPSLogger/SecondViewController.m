//
//  SecondViewController.m
//  GPSLogger
//
//  Created by Aaron Parecki on 9/17/15.
//  Copyright © 2015 Esri. All rights reserved.
//

#import "SecondViewController.h"
#import "GLManager.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    self.pausesAutomatically.on = [GLManager sharedManager].pausesAutomatically;
    self.apiEndpointField.text = [[NSUserDefaults standardUserDefaults] stringForKey:GLAPIEndpointDefaultsName];
    self.activityType.selectedSegmentIndex = [GLManager sharedManager].activityType - 1;

    GLSignificantLocationMode slMode = [GLManager sharedManager].significantLocationMode;
    switch(slMode) {
        case kGLSignificantLocationDisabled:
            self.significantLocationMode.selectedSegmentIndex = 0;
            break;
        case kGLSignificantLocationEnabled:
            self.significantLocationMode.selectedSegmentIndex = 1;
            break;
        case kGLSignificantLocationExclusive:
            self.significantLocationMode.selectedSegmentIndex = 2;
            break;
    }
    
    CLLocationDistance gDist = [GLManager sharedManager].resumesAfterDistance;
    int gIdx = 0;
    switch((int)gDist) {
        case -1:
            gIdx = 0; break;
        case 100:
            gIdx = 1; break;
        case 200:
            gIdx = 2; break;
        case 500:
            gIdx = 3; break;
        case 1000:
            gIdx = 4; break;
        case 2000:
            gIdx = 5; break;
    }
    self.resumesWithGeofence.selectedSegmentIndex = gIdx;
    
    CLLocationAccuracy d = [GLManager sharedManager].desiredAccuracy;
    if(d == kCLLocationAccuracyBestForNavigation) {
        self.desiredAccuracy.selectedSegmentIndex = 0;
    } else if(d == kCLLocationAccuracyBest) {
        self.desiredAccuracy.selectedSegmentIndex = 1;
    } else if(d == kCLLocationAccuracyNearestTenMeters) {
        self.desiredAccuracy.selectedSegmentIndex = 2;
    } else if(d == kCLLocationAccuracyHundredMeters) {
        self.desiredAccuracy.selectedSegmentIndex = 3;
    } else if(d == kCLLocationAccuracyKilometer) {
        self.desiredAccuracy.selectedSegmentIndex = 4;
    } else if(d == kCLLocationAccuracyThreeKilometers) {
        self.desiredAccuracy.selectedSegmentIndex = 5;
    }
    
    CLLocationDistance dist = [GLManager sharedManager].defersLocationUpdates;
    if(dist == 0) {
        self.defersLocationUpdates.selectedSegmentIndex = 0;
    } else if(dist == 100.0) {
        self.defersLocationUpdates.selectedSegmentIndex = 1;
    } else if(dist == 1000.0) {
        self.defersLocationUpdates.selectedSegmentIndex = 2;
    } else if(dist == 5000.0) {
        self.defersLocationUpdates.selectedSegmentIndex = 3;
    } else {
        self.defersLocationUpdates.selectedSegmentIndex = 4;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)togglePausesAutomatically:(UISwitch *)sender {
    [GLManager sharedManager].pausesAutomatically = sender.on;
    if(sender.on == NO) {
        self.resumesWithGeofence.selectedSegmentIndex = 0;
        [GLManager sharedManager].resumesAfterDistance = -1;
    }
}

- (IBAction)resumeWithGeofenceWasChanged:(UISegmentedControl *)sender {
    CLLocationDistance distance = -1;
    switch(sender.selectedSegmentIndex) {
        case 0:
            distance = -1; break;
        case 1:
            distance = 100; break;
        case 2:
            distance = 200; break;
        case 3:
            distance = 500; break;
        case 4:
            distance = 1000; break;
        case 5:
            distance = 2000; break;
    }
    if(distance > 0) {
        self.pausesAutomatically.on = YES;
        [GLManager sharedManager].pausesAutomatically = YES;
    }
    [GLManager sharedManager].resumesAfterDistance = distance;
}

- (IBAction)significantLocationModeWasChanged:(UISegmentedControl *)sender {
    GLSignificantLocationMode m = kGLSignificantLocationDisabled;
    switch(sender.selectedSegmentIndex) {
        case 0:
            m = kGLSignificantLocationDisabled; break;
        case 1:
            m = kGLSignificantLocationEnabled; break;
        case 2:
            m = kGLSignificantLocationExclusive; break;
    }
    [GLManager sharedManager].significantLocationMode = m;
}

- (IBAction)activityTypeControlWasChanged:(UISegmentedControl *)sender {
    [GLManager sharedManager].activityType = sender.selectedSegmentIndex + 1; // activityType is an enum starting at 1
}

- (IBAction)desiredAccuracyWasChanged:(UISegmentedControl *)sender {
    CLLocationAccuracy d = -999;
    switch(sender.selectedSegmentIndex) {
        case 0:
            d = kCLLocationAccuracyBestForNavigation; break;
        case 1:
            d = kCLLocationAccuracyBest; break;
        case 2:
            d = kCLLocationAccuracyNearestTenMeters; break;
        case 3:
            d = kCLLocationAccuracyHundredMeters; break;
        case 4:
            d = kCLLocationAccuracyKilometer; break;
        case 5:
            d = kCLLocationAccuracyThreeKilometers; break;
    }
    // Deferred updates only work when desired accuracy is Navigation or Best, so change to "Best" if it's worse
    if(sender.selectedSegmentIndex >= 2) {
        self.defersLocationUpdates.selectedSegmentIndex = 0;
        [GLManager sharedManager].defersLocationUpdates = 0;
    }
    if(d != -999)
        [GLManager sharedManager].desiredAccuracy = d;
}

- (IBAction)defersLocationUpdatesWasChanged:(UISegmentedControl *)sender {
    CLLocationDistance d = CLLocationDistanceMax;
    switch(sender.selectedSegmentIndex) {
        case 0:
            d = 0; break;
        case 1:
            d = 100.0; break;
        case 2:
            d = 1000.0; break;
        case 3:
            d = 5000.0; break;
        case 4:
            d = CLLocationDistanceMax; break;
    }
    if(d > 0) {
        // Deferred updates only work when desired accuracy is Navigation or Best, so change to "Best" if it's worse
        if(self.desiredAccuracy.selectedSegmentIndex >= 2) {
            self.desiredAccuracy.selectedSegmentIndex = 1;
            [GLManager sharedManager].desiredAccuracy = kCLLocationAccuracyBest;
        }
    }
    [GLManager sharedManager].defersLocationUpdates = d;
}


@end
