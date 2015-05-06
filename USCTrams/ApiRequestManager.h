//
//  ApiHelper.h
//  Touchiq
//
//  Created by Hemanth on 17/07/14.
//  Copyright (c) 2014 Hemanth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface ApiRequestManager : AFHTTPSessionManager
+(instancetype)client;
@end
