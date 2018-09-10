//
//  XJSecondViewController.m
//  XJNavigationBarHidden_Example
//
//  Created by Shawnge on 2018/8/22.
//  Copyright © 2018 zhiling1991@gmail.com. All rights reserved.
//

#import "XJSecondViewController.h"
#import "UINavigationController+XJNavigationBarHidden.h"

@interface XJSecondViewController ()

@end

@implementation XJSecondViewController

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.xj_navigationBarHidden = YES;
//    self.xj_interactivePopDisabled = YES;
    // Do any additional setup after loading the view.
}

- (IBAction)click:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
