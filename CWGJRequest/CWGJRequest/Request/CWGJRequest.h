//
//  CWGJRequest.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWGJRequestConvertible.h"
#import "CWGJCancelable.h"

typedef void(^CWGJReuqestProgressBlock)(NSProgress *progress);
typedef NSURL *(^CWGJRequestDestinationBlock)(NSURL *targetPath, NSURLResponse *response);

@interface CWGJRequest : NSObject <CWGJCancelable>

@property (nonatomic, strong, readonly) NSProgress *progress;

- (BOOL)isRequesting;
- (void)addToCancelableBag:(CWGJCancelableBag *)cancelableBag;
- (CWGJRequest *)progress:(CWGJReuqestProgressBlock)progressBlock;
- (CWGJRequest *)response:(CWGJRequestCompletionBlock)completion;

@end

@interface CWGJRequestManager : NSObject

+ (instancetype)sharedManager;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;
- (void)cancelAllRequests;

- (CWGJRequest *)request:(id<CWGJRequestConvertible>)requestConvertible;
- (CWGJRequest *)upload:(id<CWGJRequestConvertible>)requestConvertible fromFile:(NSURL *)fileURL;
- (CWGJRequest *)upload:(id<CWGJRequestConvertible>)requestConvertible fromData:(NSData *)data;
- (CWGJRequest *)download:(id<CWGJRequestConvertible>)requestConvertible
               resumeData:(NSData *)resumeData
              destination:(CWGJRequestDestinationBlock)destination;

@end

// c style method
void cancelAllRequests();
CWGJRequest *request(id<CWGJRequestConvertible> requestConvertible);
CWGJRequest *uploadFile(id<CWGJRequestConvertible> requestConvertible, NSURL *fileURL);
CWGJRequest *uploadData(id<CWGJRequestConvertible> requestConvertible, NSData *bodyData);
CWGJRequest *download(id<CWGJRequestConvertible>  requestConvertible, NSData *resumeData, CWGJRequestDestinationBlock destination);
