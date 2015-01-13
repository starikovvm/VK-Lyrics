//
//  VKAPI.h
//  VK simple client
//
//  Created by Виктор Стариков on 11.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol VKAPIDelegate <NSObject>

@required

-(NSString*)requestTokenWithURL:(NSURL*)URL;

@end

@interface VKAPI : NSObject

+ (VKAPI *)sharedInstance;
- (void) saveToken:(NSString*)token;
- (NSString*) getToken;

@property (weak, nonatomic) id<VKAPIDelegate> delegate;
@property (strong, nonatomic) NSString* token;

@end
