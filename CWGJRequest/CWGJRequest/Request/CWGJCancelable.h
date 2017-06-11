//
//  CWGJCancelable.h
//  CWGJRequest
//
//  Created by renxinwei on 2017/6/11.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CWGJCancelable <NSObject>

- (void)cancel;

@end

@interface CWGJCancelableBag : NSObject <CWGJCancelable>

- (void)addCancelable:(id<CWGJCancelable>)cancelable;

@end

@interface NSObject (CWGJCancelableBag)

@property (nonatomic, strong, readonly) CWGJCancelableBag *cancelableBag;

@end
