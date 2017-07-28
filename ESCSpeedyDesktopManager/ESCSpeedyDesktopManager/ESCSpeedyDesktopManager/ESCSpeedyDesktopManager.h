//
//  ESCSpeedyDesktopManager.h
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 28/07/2017.
//  Copyright © 2017 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ESCSpeedyDesktopManager : NSObject

+ (void)creatSpeedyDesktopWithImage:(UIImage *)image title:(NSString *)title  appURLSchemes:(NSString *)appURLSchemes;

@end
