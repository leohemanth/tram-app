//
//  Route.m
//  USCTrams
//
//  Created by Hemanth on 28/06/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import "Route.h"
#import <AFNetworking/AFNetworking.h>

@implementation Route
-(void)loadAddTheRoutes{
    NSMutableArray *routes=[NSMutableArray array];
    NSString *string = [NSString stringWithFormat:@"http://usctrams.com/region/0/routes"];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
        Route *r=[[Route alloc] init];
        r.routeID=responseObject[@"ID"];
        r.arrivalsShowVehilceName=responseObject[@"ArrivalsEnabled"];
        r.displayName = responseObject[@"DisplayName"];
        r.customerID = responseObject[@"CustomerID"];
        r.directionStops = responseObject[@"DirectionStops"];
        r.points = responseObject[@"Points"];
        r.color = responseObject[@"Color"];
        r.textColor = responseObject[@"TextColor"];
        r.arrivalsShowVehilceName = responseObject[@"ArrivalsShowVehicleNames"];
        r.isHeadway = responseObject[@"IsHeadway"];
        r.showLine = responseObject[@"ShowLine"];
        r.name = responseObject[@"Name"];
        r.shortName = responseObject[@"ShortName"];
        r.reginIDs = responseObject[@"RegionIDs"];
        r.fordwardDirectionName = responseObject[@"ForwardDirectionName"];
        r.backwordDirectionName = responseObject[@"BackwardDirectionName"];
        r.numberOfVehicles = responseObject[@"NumberOfVehicles"];
        r.patterns = responseObject[@"Patterns"];
        [routes addObject:r];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error importing routes");
    }];
    
    [operation start];
    
}
@end
