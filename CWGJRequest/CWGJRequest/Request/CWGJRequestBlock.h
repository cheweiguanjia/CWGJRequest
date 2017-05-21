//
//  CWGJRequestBlock.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//


@class CWGJResponse, RKMapping;

typedef void (^CWGJRequestCompletionBlock)(CWGJResponse *response);
typedef id (^CWGJJSONMapBlock)(id json);
typedef RKMapping *(^CWGJMappingBlock)(void);
