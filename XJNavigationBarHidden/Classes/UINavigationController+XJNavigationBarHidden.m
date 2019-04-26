//
//  UINavigationController+XJNavigationBarHidden.m
//  XJNavigationHidden
//
//  Created by 肖健 on 2017/3/7.
//  Copyright © 2017年 肖健. All rights reserved.
//

#import "UINavigationController+XJNavigationBarHidden.h"
#import <objc/runtime.h>

typedef void (^XJViewControllerVillAppearInjectBlock)(UIViewController *viewController, BOOL animated);


@interface UIViewController (XJNavigationBarHiddenPrivate)

@property (nonatomic, copy) XJViewControllerVillAppearInjectBlock xj_willAppearInjectBlock;

@end

@implementation UIViewController (XJNavigationBarHiddenPrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method viewWillAppear_originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method viewWillAppear_swizzledMethod = class_getInstanceMethod(self, @selector(xj_viewWillAppear:));
        method_exchangeImplementations(viewWillAppear_originalMethod, viewWillAppear_swizzledMethod);
        
        Method viewWillDisappear_originalMethod = class_getInstanceMethod(self, @selector(viewWillDisappear:));
        Method viewWillDisappear_swizzledMethod = class_getInstanceMethod(self, @selector(xj_viewWillDisappear:));
        method_exchangeImplementations(viewWillDisappear_originalMethod, viewWillDisappear_swizzledMethod);
    });
}

- (void)xj_viewWillAppear:(BOOL)animated {
    [self xj_viewWillAppear:animated];
    
    if (self.xj_willAppearInjectBlock) {
        self.xj_willAppearInjectBlock(self, animated);
    }
}

- (void)xj_viewWillDisappear:(BOOL)animated {
    [self xj_viewWillDisappear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *viewController = self.navigationController.viewControllers.lastObject;
        if (viewController && !viewController.xj_navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });
}

- (XJViewControllerVillAppearInjectBlock)xj_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setXj_willAppearInjectBlock:(XJViewControllerVillAppearInjectBlock)xj_willAppearInjectBlock {
    objc_setAssociatedObject(self, @selector(xj_willAppearInjectBlock), xj_willAppearInjectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UINavigationController (XJNavigationBarHidden)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(xj_pushViewController:animated:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)xj_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    __weak typeof(self) weakSelf = self;
    XJViewControllerVillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (!strongSelf.xj_hookNavigationBarHidden) { return; }
            [strongSelf setNavigationBarHidden:viewController.xj_navigationBarHidden animated:animated];
            if (viewController.xj_navigationBarHidden == YES && viewController.xj_interactivePopDisabled == NO) {
                viewController.navigationController.interactivePopGestureRecognizer.enabled = YES;
                viewController.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)viewController.navigationController;
            }
        }
    };
    
    viewController.xj_willAppearInjectBlock = block;
    
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.xj_willAppearInjectBlock) {
        disappearingViewController.xj_willAppearInjectBlock = block;
    }
    
    if (![self.viewControllers containsObject:viewController]) {
        [self xj_pushViewController:viewController animated:animated];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.interactivePopGestureRecognizer] && [self.viewControllers count] == 1) {
        return NO;
    } else {
        return YES;
    }
}

@end

@implementation UIViewController (XJNavigationBarHidden)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
//        Method swizzledMethod = class_getInstanceMethod(self, @selector(xj_viewDidLoad));
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    });
//}
//
//- (void)xj_viewDidLoad {
//    [self xj_viewDidLoad];
//    [self xj_setupInjectBlock];
//}

- (BOOL)xj_navigationBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setXj_navigationBarHidden:(BOOL)xj_navigationBarHidden {
    objc_setAssociatedObject(self, @selector(xj_navigationBarHidden), @(xj_navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)xj_interactivePopDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setXj_interactivePopDisabled:(BOOL)xj_interactivePopDisabled {
    objc_setAssociatedObject(self, @selector(xj_interactivePopDisabled), @(xj_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)xj_hookNavigationBarHidden {
    NSNumber *hook = objc_getAssociatedObject(self, _cmd);
    if (hook) {
        return [hook boolValue];
    }
    return YES;
}

- (void)setXj_hookNavigationBarHidden:(BOOL)xj_hookNavigationBarHidden {
    objc_setAssociatedObject(self, @selector(xj_hookNavigationBarHidden), @(xj_hookNavigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//- (void)xj_setupInjectBlock {
//    XJViewControllerVillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
//        if (viewController.navigationController) {
//            if (!viewController.xj_hookNavigationBarHidden) { return; }
//
//            [viewController.navigationController setNavigationBarHidden:viewController.xj_navigationBarHidden animated:animated];
//            if (viewController.xj_navigationBarHidden == YES && viewController.xj_interactivePopDisabled == NO) {
//                viewController.navigationController.interactivePopGestureRecognizer.enabled = YES;
//                viewController.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>)viewController.navigationController;
//            }
//        }
//    };
//    self.xj_willAppearInjectBlock = block;
//}

@end
