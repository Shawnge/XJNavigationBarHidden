//
//  UINavigationController+XJNavigationBarAlpha.m
//  XJNavigationBarHidden
//
//  Created by 肖健 on 2017/9/18.
//  Copyright © 2017年 肖健. All rights reserved.
//

#import "UINavigationController+XJNavigationBarAlpha.h"
#import <objc/runtime.h>

@implementation UINavigationController (XJNavigationBarAlpha)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(@"_updateInteractiveTransition:"));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(xj_updateInteractiveTransition:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}


- (void)xj_updateInteractiveTransition:(CGFloat)percentComplete {
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator) {
            CGFloat fromAlpha = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey].xj_navigationBarAlpha ;
            CGFloat toAlpha = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey].xj_navigationBarAlpha;
            CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
            
            [self xj_updateNavigationBackground:nowAlpha];
        } else {
            [self xj_updateNavigationBackground:percentComplete];
        }
    } else {
        [self xj_updateInteractiveTransition:percentComplete];
    }
}

- (void)xj_updateNavigationBackground:(CGFloat)alpha {
    UIView *barBackgroudView = self.navigationBar.subviews[0];
    UIView *shadowView = [barBackgroudView valueForKey:@"_shadowView"];
    if (shadowView) {
        shadowView.alpha = alpha;
        shadowView.hidden = alpha == 0;
    }
    
    if (self.navigationBar.isTranslucent) {
        if (@available(iOS 10.0, *)) {
            UIView *backgroudEffectView = [barBackgroudView valueForKey:@"_backgroundEffectView"];
            if (backgroudEffectView && [self.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] == nil) {
                backgroudEffectView.alpha = alpha;
                return;
            }
        } else {
            UIView *adaptiveBackdrop = [barBackgroudView valueForKey:@"_adaptiveBackdrop"];
            UIView *backdropEffectView = [barBackgroudView valueForKey:@"_backdropEffectView"];
            if (adaptiveBackdrop && backdropEffectView) {
                backdropEffectView.alpha = alpha;
                return;
            }
        }
        
        barBackgroudView.alpha = alpha;
    }
}

- (void)xj_dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    void (^animations)(UITransitionContextViewControllerKey key) = ^(UITransitionContextViewControllerKey key) {
        CGFloat nowAlpha = [context viewControllerForKey:key].xj_navigationBarAlpha;
        [self xj_updateNavigationBackground:nowAlpha];
    };
    
    if (context.isCancelled) {
        NSTimeInterval cancalDuration = context.transitionDuration * context.percentComplete;
        [UIView animateWithDuration:cancalDuration animations:^{
            animations(UITransitionContextFromViewControllerKey);
        }];
    } else {
        NSTimeInterval finishDuration = context.transitionDuration * (1 - context.percentComplete);
        [UIView animateWithDuration:finishDuration animations:^{
            animations(UITransitionContextToViewControllerKey);
        }];
    }
}

#pragma mark - UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator) {
            if (@available(iOS 10.0, *)) {
                [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [self xj_dealInteractionChanges:context];
                }];
            } else {
                [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [self xj_dealInteractionChanges:context];
                }];
            }
            return YES;
        }
    }
    
    NSInteger n = self.viewControllers.count >= self.navigationBar.items.count ? 2 : 1;
    UIViewController *popToVC = self.viewControllers[self.viewControllers.count - n];
    [self popToViewController:popToVC animated:YES];
    return YES;
}

@end


@implementation UIViewController (XJNavigationBarAlpha)

- (CGFloat)xj_navigationBarAlpha {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setXj_navigationBarAlpha:(CGFloat)xj_navigationBarAlpha {
    CGFloat navigationBarAlpha = MAX(MIN(xj_navigationBarAlpha, 1), 0);
    objc_setAssociatedObject(self, @selector(xj_navigationBarAlpha), @(navigationBarAlpha), OBJC_ASSOCIATION_ASSIGN);
    [self.navigationController xj_updateNavigationBackground:xj_navigationBarAlpha];
}

@end
