//
//  UINavigationController+XJNavigationBarHidden.h
//  XJNavigationHidden
//
//  Created by 肖健 on 2017/3/7.
//  Copyright © 2017年 肖健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (XJNavigationBarHidden)

@end

@interface UIViewController (XJNavigationBarHidden)

@property (nonatomic, assign) BOOL xj_interactivePopDisabled; //default NO, only take effect when xj_navigationBarHidden = YES

@property (nonatomic, assign) BOOL xj_navigationBarHidden; //default NO

@property (nonatomic, assign) BOOL xj_hookNavigationBarHidden; //default YES, sometimes we want to use setNavigationBarHidden:animated: instead of xj_navigationBarHidden, so we need to close this hook feature. if set NO, the xj_navigationBarHidden will not take effect.

@end
