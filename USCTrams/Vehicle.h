//
//  Vehicle.h
//  USCTrams
//
//  Created by Hemanth on 31/07/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vehicle : NSObject
@property int vehicleID;
@property (nonatomic,retain) NSString*apcPercentage,*routeID,*patternID,*name,*hasAPC,*IconPrefic,*doorStatus,*latitude,*longitude,*speed,*heading,*updatedAt,*updatedSince;
@end
