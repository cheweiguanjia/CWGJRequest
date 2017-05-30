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
#import "RKObjectMapping.h"
#import "WeatherInfo.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, 220, 120)];
    textView.text = @"步骤1：商户在微信商户平台设置模版id（需要开通权限才能看到配置入口） 步骤2：商户调用申请签约api发起签约请求  步骤3：请求验证成功，进入微信委托代扣签约页面 步骤4：用户确认签约内容，输入支付密码，完成签约 步骤5：签约成功，微信异步返回给商户签约结果和签约协议id 步骤6：如果商户长时间未收到签约结果通知，可使用查询签约关系api进行查询 步骤7：商户收到签约结果，使用申请扣款api进行扣款 步骤8：扣款成功，微信支付将扣款结果通知给商户 步骤9：如果商户需要主动解约，可以调用申请解约api进行解约。";
    [self.view addSubview:textView];
    
    UIButton *requestBtn = [[UIButton alloc] initWithFrame:CGRectMake(220, 100, 100, 50)];
    [requestBtn setTitle:@"Request" forState:UIControlStateNormal];
    [requestBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [requestBtn addTarget:self action:@selector(requestActioin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:requestBtn];
}

- (void)requestActioin {
    CWGJRequestContext *context = [CWGJRequestContext baseRequestContext];
//    context.mapper = [CWGJJSONMapper mapperWithJSONMap:^id(id json) {
//        return json[@"weatherinfo"];
//    }];
    CWGJObjectMapper *objMapper = [CWGJObjectMapper mapperWithMappingBlock:^RKMapping *{
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[WeatherInfo class]];
        [mapping addAttributeMappingsFromArray:@[@"city", @"cityid"]];
        return mapping;
    } metaData:nil JSONMap:^id(id json) {
        return json[@"weatherinfo"];
    }];
    context.mapper = objMapper;
    [[[CWGJRequestManager sharedManager] request:context] response:^(CWGJResponse *response) {
        NSLog(@"test response:%@", response);
    }];
}


@end
