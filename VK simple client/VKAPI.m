
//
//  VKAPI.m
//  VK simple client
//
//  Created by Виктор Стариков on 11.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "VKAPI.h"

@implementation VKAPI

+(VKAPI*)sharedInstance
{
    static VKAPI * _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[VKAPI alloc] init];
    });
    return _sharedInstance;
}


- (void) saveToken:(NSString*)token
{
    _token = token;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"VK_TOKEN"];
}


- (NSString*) getToken
{
    if (_token) {
        return _token;
    }
    else
    {
        NSURL* URL = [NSURL URLWithString:@"https://oauth.vk.com/authorize?client_id=4717791&scope=friends,audio,photos,offline&redirect_uri=https://oauth.vk.com/blank.html&display=mobile&v=5.27&response_type=token"];
        _token = [self.delegate requestTokenWithURL:URL];
    }
    return _token;
}


@end
