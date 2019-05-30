//
//  ESCGCDHTTPServer.m
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 5/30/19.
//  Copyright © 2019 xiang. All rights reserved.
//

#import "ESCGCDHTTPServer.h"

@interface ESCGCDHTTPServer ()

@property(nonatomic,strong)GCDWebServer* webServer;

@end

@implementation ESCGCDHTTPServer

- (void)startWithContent:(NSString *)content {
    
    // Create server
    self.webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    [self.webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  
                                  return [GCDWebServerDataResponse responseWithHTML:content];
                                  
                              }];
    
    // Start server on port 8080
    [self.webServer startWithPort:8080 bonjourName:nil];
}

- (void)stop {
    [self.webServer stop];
}

@end
