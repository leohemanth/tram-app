//
//  Prediction.m
//  USCTrams
//
//  Created by Hemanth on 31/07/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import "Prediction.h"

@implementation Prediction
+(NSArray*)generatePredictionFromResponse:(NSDictionary*)responses{
    NSMutableArray *predictions = [NSMutableArray array];
    NSArray *pResponses = responses[@"Predictions"];
    for (NSDictionary* response in pResponses) {
        Prediction *predication = [Prediction new];
        predication.arriveTime = response[@"ArriveTime"];
        predication.busName = response[@"BusName"];
        predication.direction = response[@"Direction"];
        predication.isLayover = response[@"IsLayover"];
        predication.minutes = response[@"Minutes"];
        predication.onbreak = response[@"OnBreak"];
        predication.routeID = response[@"RouteId"];
        predication.secondsToArrival = response[@"SecondsToArrival"];
        predication.stopID = response[@"StopId"];
        predication.tripId = response[@"TripId"];
        predication.tripOrder = response[@"TripOrder"];
        predication.vehicleId = response[@"VehicleId"];
        [predictions addObject:predication];
    }
    return predictions;
}

//+(NSArray*)generatePredictionFromResponse:(NSDictionary*)responses{
//    NSMutableArray *predictions = [NSMutableArray array];
//    NSArray *pResponses = responses[@"Predictions"];
//    for (NSDictionary* response in pResponses) {
//        Prediction *predication = [Prediction new];
//        predication.arriveTime = response[@"ArriveTime"];
//        predication.busName = response[@"BusName"];
//        predication.direction = response[@"Direction"];
//        predication.isLayover = response[@"IsLayover"];
//        predication.minutes = response[@"Minutes"];
//        predication.onbreak = response[@"OnBreak"];
//        predication.routeID = response[@"RouteId"];
//        predication.secondsToArrival = response[@"SecondsToArrival"];
//        predication.stopID = response[@"StopId"];
//        predication.tripId = response[@"TripId"];
//        predication.tripOrder = response[@"TripOrder"];
//        predication.vehicleId = response[@"VehicleId"];
//        [predictions addObject:predication];
//    }
//    return predictions;
//}

@end
