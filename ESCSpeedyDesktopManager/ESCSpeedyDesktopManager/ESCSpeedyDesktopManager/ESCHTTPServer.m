//
//  ESCHTTPServer.m
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 28/07/2017.
//  Copyright © 2017 xiang. All rights reserved.
//

#import "ESCHTTPServer.h"

NSString *const ESCHTTPServerPublishServiceSuccessNotificationName = @"ESCHTTPServerPublishServiceSuccessNotificationName";

NSString *const ESCHTTPServerPublishServiceFailureNotificationName = @"ESCHTTPServerPublishServiceFailureNotificationName";

@implementation ESCHTTPServer

- (void)netServiceDidPublish:(NSNetService *)ns {
    [super netServiceDidPublish:ns];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ESCHTTPServerPublishServiceSuccessNotificationName object:nil];
    });
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict {
    [super netService:ns didNotPublish:errorDict];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ESCHTTPServerPublishServiceFailureNotificationName object:errorDict];
    });
}

@end
