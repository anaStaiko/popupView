//
//  PopupView.h
//  popupView
//
//  Created by Anastasiia Staiko on 4/14/16.
//  Copyright © 2016 Anastasiia Staiko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView

@property (nonatomic, strong)IBOutlet UIView *innerView;
@property (nonatomic, weak)UIViewController *parentVC;

+ (instancetype)defaultPopupView;

@end
