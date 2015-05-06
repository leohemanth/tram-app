//
//  ApiHelper.m
//  Touchiq
//
//  Created by Hemanth on 17/07/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import "ApiRequestManager.h"
#import "AFNetworking.h"

@implementation ApiRequestManager

+(instancetype)client{
    static ApiRequestManager * requests = nil;
    static NSString * baseURL = @"http://usctrams.com/";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requests = [[ApiRequestManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
        [requests setResponseSerializer:[AFJSONResponseSerializer serializer]];
    });
    return requests;
}

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        //        self.requestSerializer =
        //        self.responseSerializer =
    }
    return self;
}
@end
