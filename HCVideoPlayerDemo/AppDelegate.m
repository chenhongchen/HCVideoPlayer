//
//  AppDelegate.m
//  HCVideoPlayerDemo
//
//  Created by chc on 2021/2/23.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HCNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ViewController *rootVc = [[ViewController alloc] init];
    HCNavigationController *nvc = [[HCNavigationController alloc] initWithRootViewController:rootVc];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nvc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyWindow];
    return YES;
}


@end
