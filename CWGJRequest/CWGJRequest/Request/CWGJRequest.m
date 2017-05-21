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
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, strong) NSMutableArray<CWGJRequestCompletionBlock> *completionBlocks;
@property (nonatomic, strong) CWGJResponse *response;

@property (nonatomic, copy) CWGJReuqestProgressBlock progressBlock;

@end

@implementation CWGJRequest

- (void)dealloc {
    [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount))];
}

- (void)setProgress:(NSProgress *)progress {
    [_progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(completedUnitCount))];
    _progress = progress;
    [_progress addObserver:self
                forKeyPath:NSStringFromSelector(@selector(completedUnitCount))
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(completedUnitCount))]) {
        if (self.progressBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressBlock(self.progress);
            });
        }
    }
}

- (CWGJRequest *)progress:(CWGJReuqestProgressBlock)progressBlock {
    self.progressBlock = progressBlock;
    return self;
}

- (BOOL)isRequesting {
    return self.task && (self.task.state == NSURLSessionTaskStateRunning || self.task.state == NSURLSessionTaskStateSuspended);
}

- (CWGJRequest *)response:(CWGJRequestCompletionBlock)completion {
    if (!self.completionBlocks) {
        self.completionBlocks = [NSMutableArray arrayWithCapacity:1];
    }
    if (completion) {
        if (self.response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(self.response);
            });
        }
        [self.completionBlocks addObject:completion];
    }
    return self;
}

- (void)dispatchCompletionsWithResponse:(CWGJResponse *)response {
    NSError *responseError = response.error;
    if (responseError && ![responseError.domain isEqualToString:CWGJRequestErrorDomain] && responseError.code != NSURLErrorCancelled) {
        NSString *errorDescription = NSLocalizedString(@"NetworkError", nil);
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
        NSError *error = [NSError errorWithDomain:CWGJRequestErrorDomain
                                             code:CWGJRequestErrorNetwork
                                         userInfo:userInfo];
        response.error = error;
    }
    self.response = response;
    for (CWGJRequestCompletionBlock block in self.completionBlocks) {
        block(response);
    }
}

@end

/***************************************************************************************************/
#pragma mark -

typedef void (^CompletionHandler)(NSURLResponse *URLResponse, id data, NSError *error);
CompletionHandler completionHandler(CWGJRequest *request, id<CWGJRequestConvertible> requestConvertible) {
    return ^(NSURLResponse *URLResponse, id data, NSError *error) {
        if (request.progress.completedUnitCount != request.progress.totalUnitCount) {
            request.progress.totalUnitCount = request.progress.completedUnitCount;
            if (request.progressBlock) {
                request.progressBlock(request.progress);
            }
        }
        CWGJResponse *response = [[CWGJResponse alloc] initWithURLResponse:URLResponse data:data];
        response.error = error;
        if ([requestConvertible respondsToSelector:@selector(responseDeserialize:completion:)]) {
            [requestConvertible responseDeserialize:response completion:^(CWGJResponse *response) {
                [request dispatchCompletionsWithResponse:response];
            }];
        } else {
            [request dispatchCompletionsWithResponse:response];
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
        request.task = [self.sessionManager uploadTaskWithStreamedRequest:URLRequest
                                                                 progress:nil
                                                        completionHandler:completionHandler(request, requestConvertible)];
        request.progress = [self.sessionManager uploadProgressForTask:request.task];
        
    } else {
        request.task = [self.sessionManager dataTaskWithRequest:URLRequest
                                              completionHandler:completionHandler(request, requestConvertible)];
        request.progress = [self.sessionManager downloadProgressForTask:request.task];
    }
    [request.task resume];
}

- (CWGJRequest *)request:(id<CWGJRequestConvertible>)requestConvertible {
    CWGJRequest *request = [CWGJRequest new];
    [self request:request convertible:requestConvertible];
    return request;
}

- (CWGJRequest *)asyncRequest:(id<CWGJRequestConvertible> (^)(void))requestConvertibleBlock {
    NSParameterAssert(requestConvertibleBlock);
    CWGJRequest *request = [CWGJRequest new];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id<CWGJRequestConvertible> requestConvertible = requestConvertibleBlock();
        [weakSelf request:request convertible:requestConvertible];
    });
    return request;
}

@end