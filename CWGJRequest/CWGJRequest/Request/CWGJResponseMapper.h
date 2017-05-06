//
//  CWGJResponseMapper.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/4.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWGJRequestBlock.h"
#import "CWGJResponse.h"

@protocol CWGJMapper <NSObject>

- (void)mapResponse:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion;

@end

@interface CWGJDataMapper : NSObject <CWGJMapper>

+ (instancetype)mapper;

@end

@interface CWGJJSONMapper : NSObject <CWGJMapper>

+ (instancetype)mapper;
+ (instancetype)mapperWithJSONMap:(CWGJJSONMapBlock)JSONMap;

@end

@interface CWGJObjectMapper : NSObject <CWGJMapper>

+ (instancetype)mapper;


@end
