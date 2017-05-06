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

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CWGJRequestContext *context = [CWGJRequestContext baseRequestContext];
    [[CWGJRequestManager sharedManager] request:context];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
