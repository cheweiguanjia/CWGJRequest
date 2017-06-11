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

- (void)cancel {
    if (self.response.cancelBlock) {
        self.response.cancelBlock();
        self.response.cancelBlock = nil;
    }
    [self.task cancel];
}

- (void)addToCancelableBag:(CWGJCancelableBag *)cancelableBag {
    [cancelableBag addCancelable:self];
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
#pragma mark - c

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

+ (instancetype)sharedManager {
    static CWGJRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [CWGJRequestManager new];
    });
    return manager;
}

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

- (void)cancelAllRequests {
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task cancel];
    }];
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

- (CWGJRequest *)upload:(id<CWGJRequestConvertible>)requestConvertible fromFile:(NSURL *)fileURL {
    CWGJRequest *request = [CWGJRequest new];
    NSURLRequest *URLRequest = [requestConvertible requestSerialize];
    request.task = [self.sessionManager uploadTaskWithRequest:URLRequest
                                                     fromFile:fileURL
                                                     progress:nil
                                            completionHandler:completionHandler(request, requestConvertible)];
    request.progress = [self.sessionManager uploadProgressForTask:request.task];
    [request.task resume];
    return request;
}

- (CWGJRequest *)upload:(id<CWGJRequestConvertible>)requestConvertible fromData:(NSData *)data {
    CWGJRequest *request = [CWGJRequest new];
    NSURLRequest *URLRequest = [requestConvertible requestSerialize];
    request.task = [self.sessionManager uploadTaskWithRequest:URLRequest
                                                     fromData:data
                                                     progress:nil
                                            completionHandler:completionHandler(request, requestConvertible)];
    request.progress = [self.sessionManager uploadProgressForTask:request.task];
    [request.task resume];
    return request;
}

- (CWGJRequest *)download:(id<CWGJRequestConvertible>)requestConvertible
               resumeData:(NSData *)resumeData
              destination:(CWGJRequestDestinationBlock)destination {
    CWGJRequest *request = [CWGJRequest new];
    NSURLRequest *URLRequest = [requestConvertible requestSerialize];
    if (resumeData) {
        request.task = [self.sessionManager downloadTaskWithResumeData:resumeData
                                                              progress:nil
                                                           destination:destination
                                                     completionHandler:completionHandler(request, requestConvertible)];
    } else {
        request.task = [self.sessionManager downloadTaskWithRequest:URLRequest
                                                           progress:nil
                                                        destination:destination
                                                  completionHandler:completionHandler(request, requestConvertible)];
    }
    request.progress = [self.sessionManager downloadProgressForTask:request.task];
    [request.task resume];
    return request;
}

@end

// c style method
void cancelAllRequest() {
    [[CWGJRequestManager sharedManager] cancelAllRequests];
}

CWGJRequest *request(id<CWGJRequestConvertible> requestConvertible) {
    return [[CWGJRequestManager sharedManager] request:requestConvertible];
}

CWGJRequest *uploadFile(id<CWGJRequestConvertible> requestConvertible, NSURL *fileURL) {
    return [[CWGJRequestManager sharedManager] upload:requestConvertible fromFile:fileURL];
}

CWGJRequest *uploadData(id<CWGJRequestConvertible> requestConvertible, NSData *bodyData) {
    return [[CWGJRequestManager sharedManager] upload:requestConvertible fromData:bodyData];
}

CWGJRequest *download(id<CWGJRequestConvertible> requestConvertible, NSData *resumeData, CWGJRequestDestinationBlock destination) {
    return [[CWGJRequestManager sharedManager] download:requestConvertible resumeData:resumeData destination:destination];
}
