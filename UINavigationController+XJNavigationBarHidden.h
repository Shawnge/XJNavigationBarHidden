//
//  Created by 肖健 on 2017/3/7.
//  Copyright © 2017年 肖健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (XJNavigationBarHidden)

@end

@interface UIViewController (XJNavigationBarHidden)

@property (nonatomic, assign) BOOL xj_interactivePopDisabled; //default NO, only use when xj_navigationBarHidden = YES

@property (nonatomic, assign) BOOL xj_navigationBarHidden; //default NO

@end
