//
//  MyAnnotation.h
//  5-地图搜索附近
//
//  Created by qianfeng on 15/12/26.
//  Copyright (c) 2015年 李庆生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
//附加一个url
@property (nonatomic, strong) NSURL *url;

@end
