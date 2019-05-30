//
//  ESCGCDHTTPServer.h
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 5/30/19.
//  Copyright © 2019 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ESCGCDHTTPServer : NSObject

- (void)start;

@end

NS_ASSUME_NONNULL_END
