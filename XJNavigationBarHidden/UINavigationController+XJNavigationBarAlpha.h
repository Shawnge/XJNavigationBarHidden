//
//  UINavigationController+XJNavigationBarAlpha.h
//  XJNavigationBarHidden
//
//  Created by 肖健 on 2017/9/18.
//  Copyright © 2017年 肖健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (XJNavigationBarAlpha) <UINavigationBarDelegate>

@end

@interface UIViewController (XJNavigationBarAlpha)

@property (nonatomic, assign) CGFloat xj_navigationBarAlpha;

@end
