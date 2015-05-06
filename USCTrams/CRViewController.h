//
//  CRViewController.h
//  USC Trams
//
//  Created by Lolcat on 31/01/2013.
//  Copyright (c) 2013 Createch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <NUI/UIView+NUI.h>
#import <NUI/UILabel+NUI.h>
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@interface CRViewController : UITableViewController <CLLocationManagerDelegate,UIWebViewDelegate>

@property (nonatomic,retain) NSURLConnection *nearbyConnection;
@property (nonatomic,retain)  NSURLConnection *arrivalsConnection;
@property (nonatomic,retain)  NSMutableData *nearbyData;
@property (nonatomic,retain)  NSDictionary *routes;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic,retain) NSDictionary *stops;
@property (nonatomic,retain)  NSArray *stopNames;
/* used for the sections in the tableview.
    uniqueStops: {
        "Maple":3, // (number of rows in section, aka buses arriving to this stop)
        "Holly":3,
        "MSC":5
     }
 */
@property (nonatomic,retain)  UIBarButtonItem *refreshBarBtn;
@property (nonatomic,retain)  UIButton *refreshBtn;
@property (nonatomic,retain)  UILabel *arrivalTimeLabel;

@property (strong, nonatomic) IBOutlet UITableView *locationsTableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

- (void)fetchNearbyStops;
//- (void)fetchArrivalsForStop:(NSString *)stopId;
@end
