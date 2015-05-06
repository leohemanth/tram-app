//
//  Vehicle.m
//  USCTrams
//
//  Created by Hemanth on 31/07/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle
+(NSArray*)generateVehicleFromResponse:(NSArray*)responses{
    NSMutableArray *vehicles= [NSMutableArray new];
    for (NSDictionary* response in responses) {
        Vehicle *vehicle =[Vehicle new];
        vehicle.vehicleID = [response[@"ID"] intValue];
        vehicle.apcPercentage = response[@"APCPercentage"];
        vehicle.routeID = response[@"RouteId"];
        vehicle.patternID = response[@"PatternId"];
        vehicle.name = response[@"Name"];
        vehicle.hasAPC = response[@"HasAPC"];
        vehicle.IconPrefic = response[@"IconPrefix"];
        vehicle.doorStatus = response[@"DoorStatus"];
        vehicle.latitude = response[@"Coordinate"][@"Latitude"];
        vehicle.longitude = response[@"Coordinate"][@"Longitude"];
        vehicle.speed = response[@"speed"];
        vehicle.heading = response[@"Heading"];
        vehicle.updatedAt = response[@"Updated"];
        vehicle.updatedSince = response[@"UpdatedAgo"];
        [vehicles addObject:vehicle];
    }
    return vehicles;
}
@end
