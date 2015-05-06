//
//  Prediction.h
//  USCTrams
//
//  Created by Hemanth on 31/07/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Prediction : NSObject
@property (nonatomic,retain)NSString *arriveTime,*busName,*direction,*isLayover,*minutes,*onbreak,*routeID,*secondsToArrival,*stopID,*tripId,*tripOrder,*vehicleId;
+(NSArray*)generatePredictionFromResponse:(NSDictionary*)response;
@end
