//
//  ViewController.m
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 28/07/2017.
//  Copyright © 2017 xiang. All rights reserved.
//

#import "ViewController.h"
#import "ESCSpeedyDesktopManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",NSHomeDirectory());
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCustomBackGroundColor:) name:@"changeBackGroundColor" object:nil];
}

- (void)setCustomBackGroundColor:(NSNotification *)notification {
    NSString *string = notification.object;
    NSLog(@"string = %@",string);
    if ([string containsString:@"blue"]) {
        self.view.backgroundColor = [UIColor blueColor];
    }else if ([string containsString:@"red"]) {
        self.view.backgroundColor = [UIColor redColor];
    }
}

- (IBAction)didClickBlueButton:(id)sender {
    [[ESCSpeedyDesktopManager sharedSpeedyDesktopManager] creatSpeedyDesktopWithImage:[UIImage imageNamed:@"student"] title:@"blue" appURLSchemes:@"escspeedydesktop://color:blue" success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)didClickRedButton:(id)sender {
    [[ESCSpeedyDesktopManager sharedSpeedyDesktopManager] creatSpeedyDesktopWithImage:[UIImage imageNamed:@"student"] title:@"red" appURLSchemes:@"escspeedydesktop://color:red" success:^{
        
    } failure:^(NSError *error) {
        
    }];

}

@end
