//
//  CWGJRequestContext.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/6.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJRequestContext.h"

@implementation CWGJRequestContext

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 30.f;
        self.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        self.method = CWGJRequestMethodGET;
        _headers = [NSMutableDictionary dictionary];
        _params = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public

- (void)addHeader:(id)header forKey:(NSString *)key {
    [self if:YES addHeader:header forKey:key];
}

- (void)if:(BOOL)flag addHeader:(id)header forKey:(NSString *)key {
    if (flag && key && header) {
        _headers[key] = header;
    }
}

- (void)addParam:(id)param forKey:(NSString *)key {
    [self if:YES addParam:param forKey:key];
}

- (void)if:(BOOL)flag addParam:(id)param forKey:(NSString *)key {
    if (flag && key && param) {
        _params[key] = param;
    }
}

- (NSURL *)URL {
    NSParameterAssert(self.baseURL != nil || self.path.length > 0);
    if (self.path) {
        return [NSURL URLWithString:self.path relativeToURL:self.baseURL];
    } else {
        return [NSURL URLWithString:@"" relativeToURL:self.baseURL];
    }
}

#pragma mark - CWGJRequestConvertible

- (NSMutableURLRequest *)requestSerialize {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithMethod:self.method
                                                                URLString:self.URL.absoluteString
                                                                   params:self.params
                                                                  headers:self.headers
                                                    constructingBodyBlock:self.constructingBodyBlock];
    request.timeoutInterval = self.timeoutInterval;
    request.cachePolicy = self.cachePolicy;
    return request;
}

- (void)responseDeserialize:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion {
    if (!response.error && [self.mapper respondsToSelector:@selector(mapResponse:completion:)]) {
        [self.mapper mapResponse:response completion:completion];
    } else {
        completion(response);
    }
}

#pragma mark - Factory

+ (instancetype)requestContext {
    return [self new];
}

@end
