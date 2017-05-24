//
//  CWGJRequest.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWGJRequestConvertible.h"

typedef void(^CWGJReuqestProgressBlock)(NSProgress *progress);
typedef NSURL *(^CWGJRequestDestinationBlock)(NSURL *targetPath, NSURLResponse *response);

@interface CWGJRequest : NSObject

@property (nonatomic, strong, readonly) NSProgress *progress;

- (CWGJRequest *)progress:(CWGJReuqestProgressBlock)progressBlock;

- (BOOL)isRequesting;
- (CWGJRequest *)response:(CWGJRequestCompletionBlock)completion;

@end

@interface CWGJRequestManager : NSObject

@property (nonatomic, strong, readonly) NSURLSession *session;

+ (instancetype)sharedManager;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

- (void)cancelAllRequests;

- (CWGJRequest *)request:(id<CWGJRequestConvertible>)requestConvertible;
- (CWGJRequest *)asyncRequest:(id<CWGJRequestConvertible> (^)(void))requestConvertibleBlock;

@end
