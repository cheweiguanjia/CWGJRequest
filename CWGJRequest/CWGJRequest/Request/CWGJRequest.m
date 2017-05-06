//
//  CWGJRequest.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJRequest.h"
#import <AFNetworking/AFNetworking.h>
#import "CWGJRequestError.h"

@interface CWGJRequest ()

@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation CWGJRequest

@end

/***************************************************************************************************/
#pragma mark -

typedef void (^CompletionHandler)(NSURLResponse *URLResponse, id data, NSError *error);
CompletionHandler completionHandler(CWGJRequest *request, id<CWGJRequestConvertible> requestConvertible) {
    return ^(NSURLResponse *URLResponse, id data, NSError *error) {
        
        CWGJResponse *response = [[CWGJResponse alloc] initWithURLResponse:URLResponse data:data];
        response.error = error;
        if ([requestConvertible respondsToSelector:@selector(responseDeserialize:completion:)]) {
            [requestConvertible responseDeserialize:response completion:^(CWGJResponse *response) {

//                [request dispatchCompletionsWithResponse:response];
            }];
        } else {
//            [request dispatchCompletionsWithResponse:response];
        }
    };
}

@interface CWGJRequestManager ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@end

@implementation CWGJRequestManager

- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

+ (instancetype)sharedManager {
    static CWGJRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [CWGJRequestManager new];
    });
    return manager;
}

- (NSURLSession *)session {
    return self.sessionManager.session;
}

- (void)request:(CWGJRequest *)request convertible:(id<CWGJRequestConvertible>)requestConvertible {
    NSURLRequest *URLRequest = [requestConvertible requestSerialize];
    NSParameterAssert(URLRequest);
    if (URLRequest.HTTPBodyStream) {
        
    } else {
        request.task = [self.sessionManager dataTaskWithRequest:URLRequest
                                              completionHandler:completionHandler(request, requestConvertible)];
    }
    [request.task resume];
}

- (CWGJRequest *)request:(id<CWGJRequestConvertible>)requestConvertible {
    CWGJRequest *request = [CWGJRequest new];
    [self request:requestConvertible convertible:requestConvertible];
    return request;
}


@end
