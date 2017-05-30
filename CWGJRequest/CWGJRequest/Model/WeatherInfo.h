//
//  WeatherInfo.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/29.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherInfo : NSObject

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *cityid;
@property (nonatomic, strong) NSString *temp;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *qy;

@end

@interface CWGJTestObject : NSObject

@end
