//
//  ViewController.m
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 28/07/2017.
//  Copyright © 2017 xiang. All rights reserved.
//

#import "ViewController.h"
#import "ESCSpeedyDesktopManager.h"
#import "UIImage+TintColor.h"

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
    //GCDWebServer
    [[ESCSpeedyDesktopManager sharedSpeedyDesktopManager] creatSpeedyDesktopGCDWebServerWithImage:[[UIImage imageNamed:@"speedy_picture"] imageWithColor:[UIColor blueColor]] title:@"blue" appURLSchemes:@"escspeedydesktop://color:blue" success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (IBAction)didClickRedButton:(id)sender {
    //HTTPServer
    [[ESCSpeedyDesktopManager sharedSpeedyDesktopManager] creatSpeedyDesktopWithImage:[[UIImage imageNamed:@"speedy_picture"] imageWithColor:[UIColor redColor]] title:@"red" appURLSchemes:@"escspeedydesktop://color:red" success:^{
        
    } failure:^(NSError *error) {
        
    }];

}



@end
