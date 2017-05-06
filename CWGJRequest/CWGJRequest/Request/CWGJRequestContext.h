//
//  CWGJRequestContext.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/6.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWGJRequestConvertible.h"
#import "CWGJResponseMapper.h"

@interface CWGJRequestContext : NSObject <CWGJRequestConvertible>

// 请求
@property (nonatomic, assign) CWGJRequestMethod method;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong, readonly) NSURL *URL;

@property (nonatomic, strong, readonly) NSMutableDictionary *headers;
@property (nonatomic, strong, readonly) NSMutableDictionary *params;
@property (nonatomic, copy) CWGJConstructingBodyBlock constructingBodyBlock;

// 响应
@property (nonatomic, strong) id<CWGJMapper> mapper;

- (void)addHeader:(id)header forKey:(NSString *)key;
- (void)if:(BOOL)flag addHeader:(id)header forKey:(NSString *)key;
- (void)addParam:(id)param forKey:(NSString *)key;
- (void)if:(BOOL)flag addParam:(id)param forKey:(NSString *)key;

+ (instancetype)requestContext;

@end
