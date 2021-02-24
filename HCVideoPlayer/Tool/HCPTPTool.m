//
//  HCPTPTool.m
//  FLAnimatedImage
//
//  Created by chc on 2019/10/19.
//

#import "HCPTPTool.h"
#import "Peer5Kit/Peer5Sdk.h"

Peer5Sdk *g_peer;
@implementation HCPTPTool
+ (void)initPTP
{
    g_peer = [[Peer5Sdk alloc] initWithToken:@"3mx1866ptnlm56fhccw6"];
}

+ (NSURL *)PTPStreamURLForURL:(NSURL *)url
{
    return [g_peer streamURLForURL:url];
}
@end
