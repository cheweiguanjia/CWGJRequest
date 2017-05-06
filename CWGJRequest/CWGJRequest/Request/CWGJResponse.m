//
//  CWGJResponse.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJResponse.h"

@implementation CWGJResponse

- (instancetype)initWithURLResponse:(NSURLResponse *)URLResponse data:(NSData *)data {
    self = [super init];
    if (self) {
        _URLResponse = URLResponse;
        _data = data;
    }
    return self;
}

@end
