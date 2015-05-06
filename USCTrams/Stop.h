//
//  Stop.h
//  USCTrams
//
//  Created by Hemanth on 28/06/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
@interface Stop : NSObject
@property (nonatomic,retain) NSString *routeName,*routeID,*stopName,*stopID,*region,*direction;
@property (nonatomic,retain) Route *route;
@property BOOL arrivalsEnabled;
@property (nonatomic,retain) NSNumber *distance;
@property (nonatomic,retain) NSDate *arrival;
@property (nonatomic,retain) NSArray *predictions;
+(NSArray*)generateStopsFromResponse:(NSArray*)response;
+(void)fetchNearByStopsWithLat:(double)lat andLong:(double)lng;
+(void)fetchNearByStops;
@end
