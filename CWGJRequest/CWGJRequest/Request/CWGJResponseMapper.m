//
//  CWGJResponseMapper.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/4.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJResponseMapper.h"

@implementation CWGJDataMapper

+ (instancetype)mapper {
    return [self new];
}

- (void)mapResponse:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion {
    if (completion && !response.error) {
        response.responseObject = response.data;
        completion(response);
    }
}

@end

@interface CWGJJSONMapper ()

@property (nonatomic, copy) CWGJJSONMapBlock JSONMap;

@end

@implementation CWGJJSONMapper

+ (instancetype)mapper {
    return [self new];
}

+ (instancetype)mapperWithJSONMap:(CWGJJSONMapBlock)JSONMap {
    CWGJJSONMapper *mapper = [self mapper];
    mapper.JSONMap = JSONMap;
    return mapper;
}

- (void)mapResponse:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion {
    if (completion) {
        if (!response.error && response.data) {
            NSError *error = nil;
            id responseObject = [NSJSONSerialization
                                 JSONObjectWithData:response.data
                                 options:NSJSONReadingMutableContainers
                                 error:&error];
            if (self.JSONMap && responseObject) {
                responseObject = self.JSONMap(responseObject);
            }
            response.responseObject = responseObject;
            response.error = error;
            completion(response);
        } else {
            completion(response);
        }
    }
}

@end

@interface CWGJObjectMapper ()

@property (nonatomic, copy) CWGJJSONMapBlock JSONMap;

@end

@implementation CWGJObjectMapper

- (void)mapResponse:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion {
    if (completion) {
        if (!response.error && response.data) {
            NSError *error = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:response.data
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            if (self.JSONMap && responseObject) {
                responseObject = self.JSONMap(responseObject);
            }
            response.responseObject = responseObject;
            response.error = error;
            if (!response.error && response.responseObject) {
                
            }
            completion(response);
        } else {
            completion(response);
        }
    }
}

@end
