//
//  Song.h
//  VK simple client
//
//  Created by Виктор Стариков on 11.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Song : NSObject

-(Song*)initWithJSON:(id)json;

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* artist;
@property (nonatomic) int duration;
@property (nonatomic) int genreId;
@property (nonatomic) int songId;
@property (nonatomic) int lyricsId;
@property (nonatomic) int ownerId;
@property (strong, nonatomic) NSURL* URL;
@property (strong, nonatomic) NSString* URLString;

@end
