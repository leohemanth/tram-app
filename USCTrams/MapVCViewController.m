//
//  MapVCViewController.m
//  USCTram
//
//  Created by Hemanth on 08/02/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "MapVCViewController.h"
#import "MyAnnotationPoint.h"
#import "ApiRequestManager.h"
#import "Prediction.h"
@interface MapVCViewController ()
@property (nonatomic,retain) NSURLConnection *vehiclesConn;
@property (nonatomic,retain) NSMutableData *vecData;
@property (nonatomic,retain) NSArray *vecs;
@property CLLocationCoordinate2D stopcorr;
@property (nonatomic,retain) NSMutableArray *annotations;
@property (nonatomic,weak) MyAnnotationPoint *currentAnnotation;
@end

@implementation MapVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.annotations = [[NSMutableArray alloc ] init];
    self.title = self.stop.stopName;
    self.routeId = (int)[self.stop.routeID integerValue];
    self.stopId = [self.stop.stopID intValue];
    [self setDataToJson];
    [self loadTrams];
    [self setMapToDefaultLocation];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self selectAnnotation];
}

-(void)selectAnnotation{
    for (MyAnnotationPoint *myAnnotation in self.mapView.annotations) {
        if ([myAnnotation isKindOfClass:[MyAnnotationPoint class]]) {
            if ([myAnnotation.type isEqualToString:@"Stop"] &&
                [self.stop.stopID intValue] == [myAnnotation.data[@"ID"] intValue]){
                [self.mapView selectAnnotation:myAnnotation animated:YES];
                int leastpre = -1;
                for (Prediction *p in self.stop.predictions) {
                    if(leastpre==-1 || [p.minutes intValue] < leastpre){
                        leastpre = [p.minutes intValue];
                    }
                }
                if (leastpre!=-1) {
                    myAnnotation.subtitle = [NSString stringWithFormat:@"in %d min",leastpre];
                }
            }
        }
    }
}

-(IBAction) setMapToLocation:(id)sender{
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *identifier=@"TramAnnotation";
    MyAnnotationPoint * myAnnotation = annotation;
    if([myAnnotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if([[myAnnotation type] isEqualToString:@"Stop"])
        identifier=@"StopAnnotation";
    if([[myAnnotation type] isEqualToString:@"Tram"])
        identifier=@"TramAnnotation";
    if ([myAnnotation.type isEqualToString:@"Stop"] &&
        [self.stop.stopID intValue] == [myAnnotation.data[@"ID"] intValue]){
        identifier=@"BlueStopAnnotation";
    }
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
        else if ([identifier isEqualToString:@"BlueStopAnnotation"]){
            annotationView.image = [UIImage imageNamed:@"bullet_blue.png"];
            self.currentAnnotation = (MyAnnotationPoint*)annotationView;
        }
        else if ([identifier isEqualToString:@"RedTramAnnotation"])
            annotationView.image = [UIImage imageNamed:@"red_bus"];
        else
            annotationView.image = [UIImage imageNamed:@"bullet_red.png"];
    }else {
        annotationView.annotation = myAnnotation;
    }
    annotationView.canShowCallout=YES;
    annotationView.calloutOffset = CGPointMake(1,0);
    annotationView.annotation=annotation;
    return annotationView;
}

-(void)loadTrams{
    ApiRequestManager *manager = [ApiRequestManager client];
    NSString *urlString = [NSString stringWithFormat:@"http://usctrams.com/Route/%d/Vehicles",
                           self.routeId];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.vecs = responseObject;
        [self addTramsOnMap:self.vecs];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"data failed!!");
    }];
}


-(void)setDataToJson{
    ApiRequestManager* manager = [ApiRequestManager client];
    NSString *url = [NSString stringWithFormat:@"http://usctrams.com/route/%d/waypoints",self.routeId];
    MKMapView *mapview = self.mapView;
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
      MKPolyline *line =  [self getPathForRoute:responseObject[0]];
            dispatch_async(dispatch_get_main_queue(), ^{
                    [mapview addOverlay:line];
            });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"response failed!! %@",task.originalRequest);
    }];
    
    url = [NSString stringWithFormat:@"http://usctrams.com/route/%d/Direction/0/stops",self.routeId];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [self drawStops:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"response failed!! %@",task.originalRequest);
    }];
}

-(void)drawStops:(NSArray *) path{
    NSInteger numberOfSteps = path.count;
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = [((NSNumber *) path[index][@"Latitude"]) doubleValue];
        annotationCoord.longitude = [((NSNumber *) path[index][@"Longitude"]) doubleValue];
        MyAnnotationPoint *annotationPoint = [[MyAnnotationPoint alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.type = @"Stop";
        annotationPoint.data = path[index];
        annotationPoint.title=path[index][@"Name"];
        [self.mapView addAnnotation:annotationPoint];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (MKPolyline*)getPathForRoute:(NSArray *) path
{
    NSInteger numberOfSteps = path.count;
    CLLocationCoordinate2D *coordinates = malloc(sizeof(CLLocationCoordinate2D) * numberOfSteps);
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude=[path[index][@"Latitude"] doubleValue];
        coordinate.longitude=[path[index][@"Longitude"] doubleValue];
        coordinates[index] = coordinate;
    }
 
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    free(coordinates);
    return polyLine;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        lineView.lineWidth = 5;
        lineView.strokeColor = [UIColor redColor];
        lineView.fillColor = [UIColor redColor];
        return lineView;
    }
    return nil;
}

-(IBAction) setMapToDefaultLocation{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.025;
    span.longitudeDelta = 0.025;
    //HOME!
    if (self.currentLocation) {
        region.center = self.currentLocation.coordinate;
    }else{
        region.center.latitude = 34.022352;
        region.center.longitude = -118.285117;
    }
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    self.currentLocation=aUserLocation.location;
}

@end