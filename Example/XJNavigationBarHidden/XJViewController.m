//
//  XJViewController.m
//  XJNavigationBarHidden
//
//  Created by zhiling1991@gmail.com on 08/22/2018.
//  Copyright (c) 2018 zhiling1991@gmail.com. All rights reserved.
//

#import "XJViewController.h"
#import "XJSecondViewController.h"
#import "UINavigationController+XJNavigationBarHidden.h"

@interface XJViewController ()

@end

@implementation XJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.xj_navigationBarHidden = YES;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
