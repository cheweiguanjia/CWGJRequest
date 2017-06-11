//
//  CWGJCancelable.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/6/11.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "CWGJCancelable.h"
#import <objc/runtime.h>

@interface CWGJCancelableBag ()

@property (nonatomic, strong) NSHashTable<id<CWGJCancelable>> *cancelables;

@end

@implementation CWGJCancelableBag

- (void)dealloc {
    [self cancel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cancelables = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
    }
    return self;
}

- (void)addCancelable:(id<CWGJCancelable>)cancelable {
    [self.cancelables addObject:cancelable];
}

- (void)cancel {
    [[self.cancelables objectEnumerator].allObjects enumerateObjectsUsingBlock:^(id<CWGJCancelable> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [self.cancelables removeAllObjects];
}

@end

static const char NSObjectCWGJCancelableKey;

@implementation NSObject (CWGJCancelableBag)

- (CWGJCancelableBag *)cancelableBag {
    CWGJCancelableBag *bag = objc_getAssociatedObject(self, &NSObjectCWGJCancelableKey);
    if (!bag) {
        bag = [CWGJCancelableBag new];
        objc_setAssociatedObject(self, &NSObjectCWGJCancelableKey, bag, OBJC_ASSOCIATION_RETAIN);
    }
    return bag;
}

@end
