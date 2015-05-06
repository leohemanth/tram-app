//
//  MyAnnotationPoint.h
//  USCTrams
//
//  Created by Hemanth on 19/03/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MyAnnotationPoint : MKPointAnnotation
@property (nonatomic,retain) NSDictionary* data;
@property (nonatomic,retain) NSString* type;
@end
