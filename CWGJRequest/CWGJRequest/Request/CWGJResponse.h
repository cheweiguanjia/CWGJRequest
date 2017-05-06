//
//  CWGJResponse.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWGJResponse : NSObject

- (instancetype)initWithURLResponse:(NSURLResponse *)URLResponse
                               data:(NSData *)data;

@property (nonatomic, strong, readonly) NSURLResponse *URLResponse;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSDictionary *extraInfo;
@property (nonatomic, copy) void (^cancelBlock)(void);

@end
