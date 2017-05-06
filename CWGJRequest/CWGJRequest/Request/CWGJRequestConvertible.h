//
//  CWGJRequestConvertible.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/3.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWGJResponse.h"
#import "CWGJRequestBlock.h"

typedef NS_ENUM (NSInteger, CWGJRequestMethod) {
    CWGJRequestMethodGET,
    CWGJRequestMethodPOST,
    CWGJRequestMethodPUT,
    CWGJRequestMethodDELETE,
    CWGJRequestMethodHEAD,
    CWGJRequestMethodPATCH,
};

@protocol AFMultipartFormData;

typedef void (^CWGJConstructingBodyBlock)(id<AFMultipartFormData> formData);

@protocol CWGJRequestConvertible <NSObject>

- (NSMutableURLRequest *)requestSerialize;

@optional
- (void)responseDeserialize:(CWGJResponse *)response completion:(CWGJRequestCompletionBlock)completion;

@end

@interface NSMutableURLRequest (CWGJRequestConvertible)

+ (NSMutableURLRequest *)requestWithMethod:(CWGJRequestMethod)method
                                 URLString:(NSString *)URLString
                                    params:(NSDictionary *)params;

+ (NSMutableURLRequest *)requestWithMethod:(CWGJRequestMethod)method
                                 URLString:(NSString *)URLString
                                    params:(NSDictionary *)params
                                   headers:(NSDictionary *)headers
                     constructingBodyBlock:(CWGJConstructingBodyBlock)constructingBodyBlock;
@end
