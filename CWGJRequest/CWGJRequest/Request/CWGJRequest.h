//
//  CWGJRequest.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWGJRequestConvertible.h"

@interface CWGJRequest : NSObject

@end

@interface CWGJRequestManager : NSObject

@property (nonatomic, strong, readonly) NSURLSession *session;

+ (instancetype)sharedManager;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

- (void)cancelAllRequests;

- (CWGJRequest *)request:(id<CWGJRequestConvertible>)requestConvertible;
- (CWGJRequest *)asyncRequest:(id<CWGJRequestConvertible> (^)(void))requestConvertibleBlock;

@end
