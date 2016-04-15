//
//  UIViewController+popupViewController.h
//  popupViewController
//
//  Created by Anastasiia Staiko on 4/14/16.
//  Copyright © 2016 Anastasiia Staiko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopupAnimation <NSObject>
@required
- (void)showView:(UIView*)popupView overlayView:(UIView*)overlayView;
- (void)dismissView:(UIView*)popupView overlayView:(UIView*)overlayView completion:(void (^)(void))completion;

@end

@interface UIViewController (popupViewController)
@property (nonatomic, retain, readonly) UIView *popupView;
@property (nonatomic, retain, readonly) UIView *overlayView;
@property (nonatomic, retain, readonly) id<PopupAnimation> popupAnimation;

// default click background to disappear
- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation;
- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation dismissed:(void(^)(void))dismissed;

- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation backgroundClickable:(BOOL)clickable;
- (void)presentPopupView:(UIView *)popupView animation:(id<PopupAnimation>)animation backgroundClickable:(BOOL)clickable dismissed:(void(^)(void))dismissed;

- (void)dismissPopupView;
- (void)dismissPopupViewWithanimation:(id<PopupAnimation>)animation;
@end

#pragma mark - 
@interface UIView (popupViewController)
@property (nonatomic, weak, readonly) UIViewController *popupViewController;

@end