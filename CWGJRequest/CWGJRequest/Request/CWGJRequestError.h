//
//  CWGJRequestError.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/4.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#ifndef CWGJRequestError_h
#define CWGJRequestError_h

extern NSString * const CWGJRequestErrorDomain;

typedef NS_ENUM (NSInteger, CWGJRequestError) {
    CWGJRequestErrorCancel = -1,
    CWGJRequestErrorNetwork = -2,
};

#endif /* CWGJRequestError_h */
