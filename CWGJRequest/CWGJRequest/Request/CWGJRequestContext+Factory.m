//
//  CWGJRequestContext+Factory.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/6.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJRequestContext+Factory.h"

@implementation CWGJRequestContext (Factory)

+ (instancetype)baseRequestContext {
    CWGJRequestContext *context = [self requestContext];
    context.baseURL = [NSURL URLWithString:@"http://www.weather.com.cn/data/sk/101230101.html"];
    return context;
}

@end
