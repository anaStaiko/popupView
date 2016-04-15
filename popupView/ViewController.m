//
//  ViewController.m
//  popupView
//
//  Created by Anastasiia Staiko on 4/14/16.
//  Copyright © 2016 Anastasiia Staiko. All rights reserved.
//

#import "ViewController.h"
#import "PopupView.h"
#import "PopupViewAnimationFade.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)popupViewFadeAction:(id)sender {
    
    PopupView *view = [PopupView defaultPopupView];
    view.parentVC = self;
    
    [self presentPopupView:view animation:[PopupViewAnimationFade new] dismissed:^{
        NSLog(@"View is loaded");
    }];

}




@end
