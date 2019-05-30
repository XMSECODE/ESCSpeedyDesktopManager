//
//  ESCSpeedyDesktopManager.m
//  ESCSpeedyDesktopManager
//
//  Created by xiang on 28/07/2017.
//  Copyright © 2017 xiang. All rights reserved.
//

#import "ESCSpeedyDesktopManager.h"
#import "Base64.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "ESCHTTPServer.h"
#import "ESCGCDHTTPServer.h"

@interface ESCSpeedyDesktopManager ()

@property (nonatomic,strong)ESCHTTPServer *httpServer;

@property(nonatomic,strong)ESCGCDHTTPServer* gcdHttpServer;

@property (nonatomic, copy) void(^success)(void);

@property (nonatomic, copy) void(^failure)(NSError *error);

@end

static ESCSpeedyDesktopManager *staticSpeedyDesktopManager;

@implementation ESCSpeedyDesktopManager

+ (instancetype)sharedSpeedyDesktopManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticSpeedyDesktopManager = [[ESCSpeedyDesktopManager alloc] init];
    });
    return staticSpeedyDesktopManager;
}

- (void)dealloc {
    // 停止服务
    [_httpServer stop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setNotification];
    }
    return self;
}

- (void)prepare {
    
}

- (void)setNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startServerSuccess) name:ESCHTTPServerPublishServiceSuccessNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startServerFailure:) name:ESCHTTPServerPublishServiceFailureNotificationName object:nil];
}

- (void)startServerSuccess {
    NSString *urlStrWithPort = [NSString stringWithFormat:@"http://localhost:%d",[_httpServer listeningPort]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStrWithPort]];
    self.success();
}

- (void)startServerFailure:(NSNotification *)notification {
    NSError *error = [NSError errorWithDomain:@"ESCSpeedyDesktopManager" code:-1 userInfo:@{NSLocalizedDescriptionKey:notification.object}];
    NSLog(@"failure");
    self.failure(error);
}

- (void)creatSpeedyDesktopGCDWebServerWithImage:(UIImage *)image
                                          title:(NSString *)title
                                  appURLSchemes:(NSString *)appURLSchemes
                                        success:(void(^)())success
                                        failure:(void(^)(NSError *error))failure {
    self.success = success;
    self.failure = failure;
    if (self.gcdHttpServer) {
        [self.gcdHttpServer stop];
    }
    self.gcdHttpServer = [[ESCGCDHTTPServer alloc] init];
    
    NSString *content = [self createContentWithImage:image title:title appURLSchemes:appURLSchemes];
    [self.gcdHttpServer startWithContent:content];
    
    NSString *urlStrWithPort = [NSString stringWithFormat:@"http://localhost:%d",8080];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStrWithPort]];

}

- (void)creatSpeedyDesktopWithImage:(UIImage *)image
                              title:(NSString *)title
                      appURLSchemes:(NSString *)appURLSchemes
                            success:(void(^)())success
                            failure:(void(^)(NSError *error))failure {
    self.success = success;
    self.failure = failure;
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.httpServer = [[ESCHTTPServer alloc] init];
    [self.httpServer setType:@"_http._tcp."];
//    self.httpServer.port = 38563;
    //启动本地httpSever和服务器首页页面
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSString* webRootDir = [documentsPath stringByAppendingPathComponent:@"web"];
    BOOL isDirectory = YES;
    BOOL exsit = [[NSFileManager defaultManager] fileExistsAtPath:webRootDir isDirectory:&isDirectory];
    if(!exsit){
        [[NSFileManager defaultManager] createDirectoryAtPath:webRootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* mainPage = [NSString stringWithFormat:@"%@/web/index.html",documentsPath];
    
    
    BOOL result = [self writeToFile:mainPage image:image title:title appURLSchemes:appURLSchemes];
    if (result == NO) {
        NSError *error = [NSError errorWithDomain:@"ESCSpeedyDesktopManager" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"write file failure"}];
        failure(error);
        return ;
    }
    
    [self.httpServer setDocumentRoot:webRootDir];
    
    [self startServer];
}

- (void)startServer {
    // Start the server (and check for problems)
    NSError *error;
    if([_httpServer start:&error]) {

    }
    else {
        NSLog(@"startserver error = %@",error);
        self.failure(error);
    }
}

- (BOOL)writeToFile:(NSString *)path image:(UIImage *)image title:(NSString *)title  appURLSchemes:(NSString *)appURLSchemes{
    NSString* htmlStrBase64 = [self createContentWithImage:image title:title appURLSchemes:appURLSchemes];
    NSData *data = [htmlStrBase64 dataUsingEncoding:NSUTF8StringEncoding];
    return [data writeToFile:path atomically:YES];
}

- (NSString *)createContentWithImage:(UIImage *)image title:(NSString *)title  appURLSchemes:(NSString *)appURLSchemes {
    NSData* imageData = UIImagePNGRepresentation(image);
    NSString* imageDataBase64Str = [imageData base64EncodedString];
    
    NSString* contentStr = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html>\n<head>\n<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">\n<meta name=\"apple-mobile-web-app-status-bar-style\" content=\"black\">\n<meta content=\"text/html charset=UTF-8\" http-equiv=\"Content-Type\" />\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\" />\n<link rel='apple-touch-icon' href='data:image/png;base64,%@'>\n<title>%@</title>\n</head>\n<body bgcolor=\"#F0F0F0\">\n<a href=\"%@\" id=\"qbt\" style=\"display: none\"></a>\n<span id=\"msg\"></span>\n</body>\n<script>\nif (window.navigator.standalone == true)\n{\nvar lnk = document.getElementById(\"qbt\")\nvar evt = document.createEvent('MouseEvent')\nevt.initMouseEvent('click')\nlnk.dispatchEvent(evt)\n}\nelse\n{\ndocument.getElementById(\"msg\").innerHTML='<div style=\"font-size:16px;\">                             <br>\
                            <br>\
                            <head>1、点击</head>\
                            <head>屏幕下方</head>\
                            <img width=\"19.5px\" height=\"26px\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACcAAAA0CAYAAAAJ4SEAAAAEDWlDQ1BJQ0MgUHJvZmlsZQAAOI2NVV1oHFUUPrtzZyMkzlNsNIV0qD8NJQ2TVjShtLp/3d02bpZJNtoi6GT27s6Yyc44M7v9oU9FUHwx6psUxL+3gCAo9Q/bPrQvlQol2tQgKD60+INQ6Ium65k7M5lpurHeZe58853vnnvuuWfvBei5qliWkRQBFpquLRcy4nOHj4g9K5CEh6AXBqFXUR0rXalMAjZPC3e1W99Dwntf2dXd/p+tt0YdFSBxH2Kz5qgLiI8B8KdVy3YBevqRHz/qWh72Yui3MUDEL3q44WPXw3M+fo1pZuQs4tOIBVVTaoiXEI/MxfhGDPsxsNZfoE1q66ro5aJim3XdoLFw72H+n23BaIXzbcOnz5mfPoTvYVz7KzUl5+FRxEuqkp9G/Ajia219thzg25abkRE/BpDc3pqvphHvRFys2weqvp+krbWKIX7nhDbzLOItiM8358pTwdirqpPFnMF2xLc1WvLyOwTAibpbmvHHcvttU57y5+XqNZrLe3lE/Pq8eUj2fXKfOe3pfOjzhJYtB/yll5SDFcSDiH+hRkH25+L+sdxKEAMZahrlSX8ukqMOWy/jXW2m6M9LDBc31B9LFuv6gVKg/0Szi3KAr1kGq1GMjU/aLbnq6/lRxc4XfJ98hTargX++DbMJBSiYMIe9Ck1YAxFkKEAG3xbYaKmDDgYyFK0UGYpfoWYXG+fAPPI6tJnNwb7ClP7IyF+D+bjOtCpkhz6CFrIa/I6sFtNl8auFXGMTP34sNwI/JhkgEtmDz14ySfaRcTIBInmKPE32kxyyE2Tv+thKbEVePDfW/byMM1Kmm0XdObS7oGD/MypMXFPXrCwOtoYjyyn7BV29/MZfsVzpLDdRtuIZnbpXzvlf+ev8MvYr/Gqk4H/kV/G3csdazLuyTMPsbFhzd1UabQbjFvDRmcWJxR3zcfHkVw9GfpbJmeev9F08WW8uDkaslwX6avlWGU6NRKz0g/SHtCy9J30o/ca9zX3Kfc19zn3BXQKRO8ud477hLnAfc1/G9mrzGlrfexZ5GLdn6ZZrrEohI2wVHhZywjbhUWEy8icMCGNCUdiBlq3r+xafL549HQ5jH+an+1y+LlYBifuxAvRN/lVVVOlwlCkdVm9NOL5BE4wkQ2SMlDZU97hX86EilU/lUmkQUztTE6mx1EEPh7OmdqBtAvv8HdWpbrJS6tJj3n0CWdM6busNzRV3S9KTYhqvNiqWmuroiKgYhshMjmhTh9ptWhsF7970j/SbMrsPE1suR5z7DMC+P/Hs+y7ijrQAlhyAgccjbhjPygfeBTjzhNqy28EdkUh8C+DU9+z2v/oyeH791OncxHOs5y2AtTc7nb/f73TWPkD/qwBnjX8BoJ98VVBg/m8AAAHVaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA1LjQuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIj4KICAgICAgICAgPHRpZmY6Q29tcHJlc3Npb24+MTwvdGlmZjpDb21wcmVzc2lvbj4KICAgICAgICAgPHRpZmY6T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlvbj4KICAgICAgICAgPHRpZmY6UGhvdG9tZXRyaWNJbnRlcnByZXRhdGlvbj4yPC90aWZmOlBob3RvbWV0cmljSW50ZXJwcmV0YXRpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgoC2IAFAAACdElEQVRYCe1Zz2vUQBT+kkyqdqUVSot/gB70UBBK8eChope2B/Xm2eKCJw/bFaXgwaM//gHxZkE8WWqxRxFBQesPVhAteBfT9dBu6o8kG+dlcYWQMZvJBOYwD2YnM7Pvmy/feztZXizf92NoaramvBJazLIsbfmxONY2qtA6rHqTo5xT0bZ2Ldx6xkC9CjzCYFCQcp4P1B+6eLHB8PJLiLvnA4wPl/+dWZ2dTil6m20LiytDeP2O9dlMHwtw+2yAw2OloGFzow+p1v5ho0nEWgwnpsKEHPWvWm4yT+uy2Ikf6JiTaB7PrYUHQ3j7keHifICl2R456mn8hs9TqL1dOXziJHXObW7ZaDxieP/JRn3uNxozET57vcOcjs2rp0I4dox76y4WusCdcyEOjfGLglb4KGlzJa6tMmx8YGjwvFqcCVFzKbf+5lecjJsnQ1w+E/AQMyw9dvCdFCxo/7J4QMcDe4HTRyPMT0a4MBUJvWou0OTER4djkJqj3K+oFSbncK0vHReTShOoTw/+3bRv4bCmAaoca00uM6w3nzJ4nXxNxvcDV3jii6wsTia55ecOvn11RHv25ycORv8lVxYnkxztThu3rv/qE5G5GMR/8sYeIbTWOWfICeOWs2CUyxFIuGyUE0qTs2CUyxFIuGyUE0qTs6BMuX38KU3PY+pVmTKoIxNx6T8K6ZtSplwaWMXYkJNV0ShnlJNVQNbP5JxRTlYBWT/BGxwb27wI3VzjdayKbdu3MVLjxdWMN0ms282qOHbxc8fB/SfVk6N7H6lFyOJRuppepbDMsnu13Co3kcUW5JwsnFo/rQ9hqVK/Wn3EaFor9wdQdLIgmw3mTgAAAABJRU5ErkJggg==\">\
                            <head>按钮</head>\
                            <br>\
                            <br>\
                            <br>\
                            <head>2、再弹出菜单中选择</head>\
                            <img  width=\"20px\" height=\"20px\" src=\"data:image/png;base64,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\">\
                            <head>【</head>\
                            <font color=\"#0000FF\"><head>添加至主屏幕</head></font>\
                            <head>】</head>\
                            <head>方便您随时主屏幕点击快捷方式查看此方案，无需网络，节省流量</head></div>'\n}\n</script>\n</html>",imageDataBase64Str,title,appURLSchemes];
    
    NSString* contentStrBase64 = [contentStr base64EncodedString];
    
    contentStr = [contentStrBase64 stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    contentStr = [contentStr stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    contentStr = [contentStr stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    
    NSString* htmlStrBase64 = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html>\n<head lang=\"en\">\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n<meta http-equiv=\"refresh\" content=\"1; data:text/html;charset=utf-8;base64,%@\">\n</head>\n<body>\n</body>\n</html>",contentStr];
    return htmlStrBase64;
}

@end
