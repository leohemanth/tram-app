//
//  Route.h
//  USCTrams
//
//  Created by Hemanth on 28/06/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject
@property (nonatomic,retain) NSString *routeID,*displayName,*customerID,*directionStops,*points,*color,*textColor,*arrivalsShowVehilceName,*isHeadway,*showLine,*name,*shortName,*reginIDs,*fordwardDirectionName,*backwordDirectionName,*numberOfVehicles,*patterns;
@end

//ID: 1940,
//ArrivalsEnabled: true,
//DisplayName: "C C Route",
//CustomerID: 4,
//DirectionStops: null,
//Points: null,
//Color: "#05D5FF",
//TextColor: "#030303",
//ArrivalsShowVehicleNames: true,
//IsHeadway: false,
//ShowLine: true,
//Name: "C Route",
//ShortName: "C",
//RegionIDs: [ ],
//ForwardDirectionName: "Forwards",
//BackwardDirectionName: "Backwards",
//NumberOfVehicles: 0,
//Patterns: null