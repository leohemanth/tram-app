//
//  MapVCViewController.h
//  USCTram
//
//  Created by Hemanth on 08/02/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Stop.h"
@interface MapVCViewController : UIViewController<MKMapViewDelegate>
@property (nonatomic,strong) Stop *stop;
@property (nonatomic,strong) CLLocation *currentLocation;
@property(weak) IBOutlet MKMapView *mapView;
@property int routeId,stopId;
@end
