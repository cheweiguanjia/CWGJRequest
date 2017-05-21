//
//  FirstViewController.m
//  CWGJRequest
//
//  Created by renxinwei on 2017/5/2.
//  Copyright © 2017年 cheweiguanjia. All rights reserved.
//

#import "FirstViewController.h"
#import "CWGJRequestContext+Factory.h"
#import "CWGJRequestContext.h"
#import "CWGJRequest.h"
#import "CWGJResponseMapper.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *requestBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
    [requestBtn setTitle:@"Request" forState:UIControlStateNormal];
    [requestBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [requestBtn addTarget:self action:@selector(requestActioin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestBtn];
}

- (void)requestActioin {
    CWGJRequestContext *context = [CWGJRequestContext baseRequestContext];
    context.mapper = [CWGJJSONMapper mapperWithJSONMap:^id(id json) {
        return json[@"weatherinfo"];
    }];
    [[[CWGJRequestManager sharedManager] request:context] response:^(CWGJResponse *response) {
        NSLog(@"test response:%@", response);
    }];
}


@end
