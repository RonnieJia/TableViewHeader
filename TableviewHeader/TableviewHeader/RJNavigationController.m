//
//  RJNavigationController.m
//  TableviewHeader
//
//  Created by jia on 2017/5/3.
//  Copyright © 2017年 RJ. All rights reserved.
//

#import "RJNavigationController.h"

@interface RJNavigationController ()

@end

@implementation RJNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
