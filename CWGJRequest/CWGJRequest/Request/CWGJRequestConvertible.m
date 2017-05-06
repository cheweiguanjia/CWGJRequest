//
//  CWGJRequestConvertible.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/3.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJRequestConvertible.h"
#import <AFNetworking/AFNetworking.h>

NSString * stringForMethod(CWGJRequestMethod method) {
    switch (method) {
        case CWGJRequestMethodGET:
            return @"GET";
        case CWGJRequestMethodPOST:
            return @"POST";
        case CWGJRequestMethodPUT:
            return @"PUT";
        case CWGJRequestMethodDELETE:
            return @"DELETE";
        case CWGJRequestMethodHEAD:
            return @"HEAD";
        case CWGJRequestMethodPATCH:
            return @"PATCH";
        default:
            return @"GET";
    }
}

@implementation NSMutableURLRequest (CWGJRequestConvertible)

+ (NSMutableURLRequest *)requestWithMethod:(CWGJRequestMethod)method
                                 URLString:(NSString *)URLString
                                    params:(NSDictionary *)params {
    return [self requestWithMethod:method
                         URLString:URLString
                            params:params
                           headers:nil
             constructingBodyBlock:nil];
}

+ (NSMutableURLRequest *)requestWithMethod:(CWGJRequestMethod)method
                                 URLString:(NSString *)URLString
                                    params:(NSDictionary *)params
                                   headers:(NSDictionary *)headers
                     constructingBodyBlock:(CWGJConstructingBodyBlock)constructingBodyBlock {
    static AFHTTPRequestSerializer *serializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer = [AFHTTPRequestSerializer serializer];
    });
    NSMutableURLRequest *request = nil;
    NSError *error = nil;
    if (constructingBodyBlock) {
        request = [serializer multipartFormRequestWithMethod:stringForMethod(method) URLString:URLString parameters:params constructingBodyWithBlock:constructingBodyBlock error:&error];
    } else {
        request = [serializer requestWithMethod:stringForMethod(method) URLString:URLString parameters:params error:&error];
    }
    NSParameterAssert(error == nil);
    NSParameterAssert(request);
    
    return request;
}

@end
