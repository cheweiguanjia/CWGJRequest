//
//  CWGJResponseMapper.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/4.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJResponseMapper.h"
#import "CWGJRequestError.h"
#import <RestKit/ObjectMapping.h>
#import <RestKit/RKObjectMappingOperationDataSource.h>

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
@property (nonatomic, copy) CWGJMappingBlock mappingBlock;
@property (nonatomic, strong) NSDictionary *metaData;

@end

@implementation CWGJObjectMapper

+ (instancetype)mapperWithMappingBlock:(CWGJMappingBlock)mappingBlock {
    return [self mapperWithMappingBlock:mappingBlock metaData:nil JSONMap:nil];
}

+ (instancetype)mapperWithMappingBlock:(CWGJMappingBlock)mappingBlock
                              metaData:(NSDictionary *)metaData {
    return [self mapperWithMappingBlock:mappingBlock metaData:metaData JSONMap:nil];
}

+ (instancetype)mapperWithMappingBlock:(CWGJMappingBlock)mappingBlock
                              metaData:(NSDictionary *)metaData
                               JSONMap:(CWGJJSONMapBlock)JSONMap {
    NSParameterAssert(mappingBlock);
    if (mappingBlock) {
        CWGJObjectMapper *mapper = [self new];
        mapper.mappingBlock = mappingBlock;
        mapper.metaData = metaData;
        mapper.JSONMap = JSONMap;
        return mapper;
    } else {
        return nil;
    }
}

- (void)mapResponse:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion {
    if (completion) {
        if (!response.error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                RKMapping *mapping = self.mappingBlock();
                if (response.data) {
                    NSError *error = nil;
                    id responseObject = [NSJSONSerialization JSONObjectWithData:response.data
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&error];
                    if (self.JSONMap && responseObject) {
                        responseObject = self.JSONMap(responseObject);
                    }
                    response.responseObject = responseObject;
                    response.error = error;
                }
                if (!response.error && response.responseObject) {
                    RKMapperOperation *operation = [[RKMapperOperation alloc] initWithRepresentation:response.responseObject
                                                                                  mappingsDictionary:@{[NSNull null]: mapping}];
                    operation.mappingOperationDataSource = [RKObjectMappingOperationDataSource new];
                    operation.metadata = self.metaData;
                    __weak typeof(response) weakResponse = response;
                    __weak typeof(operation) weakOperation = operation;
                    response.cancelBlock = ^{
                        weakResponse.error = [NSError errorWithDomain:CWGJRequestErrorDomain
                                                                 code:CWGJRequestErrorCancel
                                                             userInfo:@{NSLocalizedDescriptionKey: @"CWGJ Cancel Request."}];
                        [weakOperation cancel];
                    };
                    [operation start];
                    if (!response.error) {
                        response.error = operation.error;
                        response.responseObject = operation.mappingResult.array;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(response);
                });
            });
        } else {
            completion(response);
        }
    }
}

@end
