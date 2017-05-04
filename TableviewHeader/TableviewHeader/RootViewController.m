//
//  RootViewController.m
//  TableviewHeader
//
//  Created by jia on 2017/5/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
