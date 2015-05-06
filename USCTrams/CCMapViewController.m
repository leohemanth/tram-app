//
//  CCMapViewController.m
//  USC Trams
//
//  Created by Hemanth on 20/10/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CCMapViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotationPoint.h"
#import "ApiRequestManager.h"
@interface CCMapViewController ()
@property (nonatomic,retain) NSArray *vecs;
@property (nonatomic,retain) NSMutableArray *annotations;
@end

@implementation CCMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTrams];
    [self drawPolyginOnMap];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)drawPolyginOnMap{
//    [self.mapView set]
    CLLocationCoordinate2D upcCoords[20]={
        CLLocationCoordinate2DMake(34.032816, -118.291801),
        CLLocationCoordinate2DMake(34.032905, -118.300421),
        CLLocationCoordinate2DMake(34.017949, -118.300309),
        CLLocationCoordinate2DMake(34.017985, -118.291812),
        CLLocationCoordinate2DMake(34.010621, -118.291726),
        CLLocationCoordinate2DMake(34.010941, -118.287134),
        CLLocationCoordinate2DMake(34.010977, -118.282199),
        CLLocationCoordinate2DMake(34.013396, -118.282328),
        CLLocationCoordinate2DMake(34.013432, -118.281513),
        CLLocationCoordinate2DMake(34.013076, -118.280440),
        CLLocationCoordinate2DMake(34.016349, -118.278251),
        CLLocationCoordinate2DMake(34.016135, -118.276878),
        CLLocationCoordinate2DMake(34.019657, -118.274560),
        CLLocationCoordinate2DMake(34.020261, -118.275891),
        CLLocationCoordinate2DMake(34.032745, -118.267908),
        CLLocationCoordinate2DMake(34.040178, -118.284302),
        CLLocationCoordinate2DMake(34.035982, -118.284173),
        CLLocationCoordinate2DMake(34.035982, -118.291641),
        CLLocationCoordinate2DMake(34.032816, -118.291801)
    };
//    CLLocationCoordinate2D hscCoords[21]={
//        CLLocationCoordinate2DMake(34.060410, -118.214736),
//        CLLocationCoordinate2DMake(34.061832, -118.212676),
//        CLLocationCoordinate2DMake(34.063966, -118.212805),
//        CLLocationCoordinate2DMake(34.065281, -118.206453),
//        CLLocationCoordinate2DMake(34.065708, -118.204393),
//        CLLocationCoordinate2DMake(34.065565, -118.202333),
//        CLLocationCoordinate2DMake(34.064570, -118.197098),
//        CLLocationCoordinate2DMake(34.066383, -118.195939),
//        CLLocationCoordinate2DMake(34.065672, -118.192720),
//        CLLocationCoordinate2DMake(34.063681, -118.192720),
//        CLLocationCoordinate2DMake(34.064499, -118.196969),
//        CLLocationCoordinate2DMake(34.054579, -118.202720),
//        CLLocationCoordinate2DMake(34.056997, -118.208342),
//        CLLocationCoordinate2DMake(34.055611, -118.209286),
//        CLLocationCoordinate2DMake(34.056037, -118.210144),
//        CLLocationCoordinate2DMake(34.057424, -118.209286),
//        CLLocationCoordinate2DMake(34.058988, -118.212891),
//        CLLocationCoordinate2DMake(34.058810, -118.213663),
//        CLLocationCoordinate2DMake(34.059166, -118.214221),
//        CLLocationCoordinate2DMake(34.060375, -118.214779),
//        CLLocationCoordinate2DMake(34.060410, -118.214736)
//    };
    MKPolygon *commuterPoly1 = [MKPolygon polygonWithCoordinates:upcCoords count:19];
//    MKPolygon *commuterPoly2 = [MKPolygon polygonWithCoordinates:hscCoords count:21];
    [self.mapView addOverlay:commuterPoly1];
//    [self.mapView addOverlay:commuterPoly2];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay{
    if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolylineRenderer *polylineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        polylineView.lineWidth = 2;
        polylineView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        polylineView.strokeColor = [UIColor redColor];
        return polylineView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *identifier=@"TramAnnotation";
    MyAnnotationPoint * myAnnotation = annotation;
    if([myAnnotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if([[myAnnotation type] isEqualToString:@"Tram"])
        identifier=@"TramAnnotation";
    if ([myAnnotation.type isEqualToString:@"Tram"] &&
        [myAnnotation.data[@"Speed"] intValue] == 0){
        identifier=@"RedTramAnnotation";
    }
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
        if ([identifier isEqualToString:@"TramAnnotation"])
            annotationView.image = [UIImage imageNamed:@"blue_bus.png"];
        else if ([identifier isEqualToString:@"RedTramAnnotation"])
            annotationView.image = [UIImage imageNamed:@"red_bus"];
    }else {
        annotationView.annotation = myAnnotation;
    }
    annotationView.canShowCallout=YES;
    annotationView.calloutOffset = CGPointMake(1,0);
    annotationView.annotation=annotation;
    return annotationView;
}

-(void)addTramsOnMap:(NSArray*)vecs{
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
    for (NSDictionary *vec in vecs) {
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [((NSNumber *) vec[@"Latitude"]) doubleValue];
        annotationCoord.longitude = [((NSNumber *) vec[@"Longitude"]) doubleValue];
        MyAnnotationPoint *annotationPoint = [[MyAnnotationPoint alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.type = @"Tram";
        annotationPoint.data = vec;
        annotationPoint.subtitle = vec[@"UpdatedAgo"];
        [self.mapView addAnnotation:annotationPoint];
        [self.annotations addObject:annotationPoint];
    }
    if([self.navigationController.visibleViewController isKindOfClass:[self class]])
        [self performSelector:@selector(loadTrams) withObject:nil afterDelay:5];
}

-(void)loadTrams{
    ApiRequestManager *manager = [ApiRequestManager client];
    NSString *urlString = [NSString stringWithFormat:@"http://cruiser.syncromatics.com/Route/330/Vehicles"];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.vecs = responseObject;
        [self addTramsOnMap:self.vecs];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"data failed!!");
    }];
}

@end
