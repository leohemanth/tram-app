//
//  Stop.m
//  USCTrams
//
//  Created by Hemanth on 28/06/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import "Stop.h"
#import "ApiRequestManager.h"
#import "Prediction.h"
#import "AppDelegate.h"
@implementation Stop
+(NSArray*)generateStopsFromResponse:(NSArray*)response{
    NSMutableArray*stops=[NSMutableArray array];
    for (NSDictionary *stopInfo in response) {
        Stop *s=[[Stop alloc] init];
        s.routeName=stopInfo[@"RouteName"];
        s.routeID = stopInfo[@"RouteId"];
        s.stopName = stopInfo[@"StopName"];
        s.stopID = stopInfo[@"StopId"];
        s.region = stopInfo[@"Region"];
        s.distance = stopInfo[@"Distance"];
        s.direction = stopInfo[@"Direction"];
        s.arrivalsEnabled = [stopInfo[@"ArrivalsEnabled"] boolValue];
        s.predictions = [NSArray new];
        [stops addObject:s];
    }
    return stops;
}

-(Route*)getRouteByID:(NSString*)routeID andName:(NSString*)routeName{
    Route* route;
    return route;
}

//+(void)getUniqueStopsFromStops:(NSArray*)stops{
//    NSMutableArray *array=[NSMutableArray array];
//    for (Stop* s in stops) {
//        statements
//    }
//}

+(void)fetchNearByStopsWithLat:(double)lat andLong:(double)lng{
    ApiRequestManager* manager = [ApiRequestManager client];
    if (lat==0) {
        lat = 34.024085;
        lng = -118.287542;
    }
    NSString *url = [NSString stringWithFormat:@"/api/nearbystops/%f/%f?format=json",lat,lng];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray* stops = [self generateStopsFromResponse:responseObject];
        [self fetchArrivalInfoForStops:stops];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"response failed!! %@",task.originalRequest);
    }];
}

+(void)fetchNearByStops{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.locationManager.location;
    [self fetchNearByStopsWithLat:currentLocation.coordinate.latitude andLong:currentLocation.coordinate.longitude];
}

+(void)fetchArrivalInfoForStops:(NSArray*)stops{
    ApiRequestManager* manager = [ApiRequestManager client];
    [self keepCountOfStops:stops.count];
    if (stops.count==0) {
        [self postNotificationIfDone:stops];
    }
    for (Stop* s in stops) {
        NSString *urlString = [NSString stringWithFormat:@"/Route/%@/Stop/%@/Arrivals",s.routeID, s.stopID];
        [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            s.predictions = [s.predictions arrayByAddingObjectsFromArray:[Prediction generatePredictionFromResponse:responseObject]];
            [self postNotificationIfDone:stops];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"failed %@",task.originalRequest);
        }];
    }
}

+(void)keepCountOfStops:(NSUInteger)count{
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"PredictionsForStopsTotal"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PredictionsDownloaded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSUInteger)getTotalStopsCounts{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"PredictionsForStopsTotal"];
}

+(void)postNotificationIfDone:(NSArray*)stops{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"PredictionsDownloaded"];
    if (count+1==stops.count || stops.count==0) {
        //group stops based on stopID
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PredictionsDownloaded"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopsUpdated" object:[self groupStops:stops]];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:count+1 forKey:@"PredictionsDownloaded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray*)groupStops:(NSArray*)stops{
    NSMutableDictionary *groupedStops = [NSMutableDictionary dictionary];
    NSMutableArray *groupNames = [NSMutableArray array];
    for (Stop *stop in stops) {
        NSMutableArray *gstops = [groupedStops objectForKey:stop.stopName];
        if(gstops){
            [gstops addObject:stop];
        }else{
            [groupNames addObject:stop.stopName];
            groupedStops[stop.stopName]= [NSMutableArray arrayWithObject:stop];
        }
    }
    return @[groupNames,groupedStops];
}
@end
