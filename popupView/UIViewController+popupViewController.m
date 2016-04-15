//
//  UIViewController+popupViewController.m
//  popupViewController
//
//  Created by Anastasiia Staiko on 4/14/16.
//  Copyright © 2016 Anastasiia Staiko. All rights reserved.
//

#import "UIViewController+popupViewController.h"
#import <objc/runtime.h>
#import "PopupBackgroundView.h"


#define kPopupView @"kPopupView"
#define kOverlayView @"kOverlayView"
#define kPopupViewDismissedBlock @"kPopupViewDismissedBlock"
#define KPopupAnimation @"KPopupAnimation"
#define kPopupViewController @"kPopupViewController"

#define kPopupViewTag 8002
#define kOverlayViewTag 8003

@interface UIView (popupViewControllerPrivate)
@property (nonatomic, weak, readwrite) UIViewController *popupViewController;
@end

@interface UIViewController (popupViewControllerPrivate)
@property (nonatomic, retain) UIView *popupView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, copy) void(^dismissCallback)(void);
@property (nonatomic, retain) id<PopupAnimation> popupAnimation;
- (UIView*)topView;
@end

@implementation UIViewController (popupViewController)

#pragma public method

- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation{
    [self _presentPopupView:popupView animation:animation backgroundClickable:YES dismissed:nil];
}

- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation dismissed:(void (^)(void))dismissed{
    [self _presentPopupView:popupView animation:animation backgroundClickable:YES dismissed:dismissed];
}

- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation backgroundClickable:(BOOL)clickable{
    [self _presentPopupView:popupView animation:animation backgroundClickable:clickable dismissed:nil];
}

- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation backgroundClickable:(BOOL)clickable dismissed:(void (^)(void))dismissed{
    [self _presentPopupView:popupView animation:animation backgroundClickable:clickable dismissed:dismissed];
}

- (void)dismissPopupViewWithanimation:(id<PopupAnimation>)animation{
    [self _dismissPopupViewWithAnimation:animation];
}

- (void)dismissPopupView{
    [self _dismissPopupViewWithAnimation:self.popupAnimation];
}
#pragma mark - inline property
- (UIView *)popupView {
    return objc_getAssociatedObject(self, kPopupView);
}

- (void)setPopupView:(UIViewController *)popupView {
    objc_setAssociatedObject(self, kPopupView, popupView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)overlayView{
    return objc_getAssociatedObject(self, kOverlayView);
}

- (void)setOverlayView:(UIView *)overlayView {
    objc_setAssociatedObject(self, kOverlayView, overlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void(^)(void))dismissCallback{
    return objc_getAssociatedObject(self, kPopupViewDismissedBlock);
}

- (void)setDismissCallback:(void (^)(void))dismissCallback{
    objc_setAssociatedObject(self, kPopupViewDismissedBlock, dismissCallback, OBJC_ASSOCIATION_COPY);
}

- (id<PopupAnimation>)popupAnimation{
    return objc_getAssociatedObject(self, KPopupAnimation);
}

- (void)setPopupAnimation:(id<PopupAnimation>)popupAnimation{
    objc_setAssociatedObject(self, KPopupAnimation, popupAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - view handle

- (void)_presentPopupView:(UIView*)popupView animation:(id<PopupAnimation>)animation backgroundClickable:(BOOL)clickable dismissed:(void(^)(void))dismissed{

    
    // check if source view controller is not in destination
    if ([self.overlayView.subviews containsObject:popupView]) return;
    
    // fix issue #2
    if (self.overlayView && self.overlayView.subviews.count > 1) {
        [self _dismissPopupViewWithAnimation:nil];
    }
    
    self.popupView = nil;
    self.popupView = popupView;
    self.popupAnimation = nil;
    self.popupAnimation = animation;
    
    UIView *sourceView = [self _topView];

    // customize popupView
    popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    popupView.tag = kPopupViewTag;
    popupView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
    popupView.layer.masksToBounds = NO;
    popupView.layer.shadowOffset = CGSizeMake(5, 5);
    popupView.layer.shadowRadius = 5;
    popupView.layer.shadowOpacity = 0.5;
    popupView.layer.shouldRasterize = YES;
    popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Add overlay
    if (self.overlayView == nil) {
        UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayView.tag = kOverlayViewTag;
        overlayView.backgroundColor = [UIColor clearColor];
        
        // BackgroundView
        UIView *backgroundView = [[PopupBackgroundView alloc] initWithFrame:sourceView.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.backgroundColor = [UIColor clearColor];
        [overlayView addSubview:backgroundView];
        
        // Make the Background Clickable
        if (clickable) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissPopupView)];
            [backgroundView addGestureRecognizer:tap];
        }
        self.overlayView = overlayView;
    }
    
    [self.overlayView addSubview:popupView];
    [sourceView addSubview:self.overlayView];

    self.overlayView.alpha = 1.0f;
    popupView.center = self.overlayView.center;
    if (animation) {
        [animation showView:popupView overlayView:self.overlayView];
    }
    
    [self setDismissCallback:dismissed];

}

- (void)_dismissPopupViewWithAnimation:(id<PopupAnimation>)animation{
    if (animation) {
        [animation dismissView:self.popupView overlayView:self.overlayView completion:^(void) {
            [self.overlayView removeFromSuperview];
            [self.popupView removeFromSuperview];
            self.popupView = nil;
            self.popupAnimation = nil;
            
            id dismissed = [self dismissCallback];
            if (dismissed != nil){
                ((void(^)(void))dismissed)();
                [self setDismissCallback:nil];
            }
        }];
    }else{
        [self.overlayView removeFromSuperview];
        [self.popupView removeFromSuperview];
        self.popupView = nil;
        self.popupAnimation = nil;
        
        id dismissed = [self dismissCallback];
        if (dismissed != nil){
            ((void(^)(void))dismissed)();
            [self setDismissCallback:nil];
        }
    }
}

-(UIView*)_topView {
    UIViewController *recentView = self;
    
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

@end

#pragma mark - UIView+popupView
@implementation UIView (popupViewController)
- (UIViewController *)popupViewController {
    return objc_getAssociatedObject(self, kPopupViewController);
}

- (void)setPopupViewController:(UIViewController * _Nullable)popupViewController {
    objc_setAssociatedObject(self, kPopupViewController, popupViewController, OBJC_ASSOCIATION_ASSIGN);
}
@end