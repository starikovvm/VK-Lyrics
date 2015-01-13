//
//  Song.m
//  VK simple client
//
//  Created by Виктор Стариков on 11.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//


/*{
 artist = Radiohead;
 duration = 261;
 "genre_id" = 2;
 id = 332094490;
 "lyrics_id" = 5963736;
 "owner_id" = 14486626;
 title = "Karma Police";
 url = "https://psv4.vk.me/c4901/u1223745/audios/39621025940d.mp3?extra=C4i8IQABiU16zk8PTnQuxhZYLDv6NZWsEZC6XtKft8pL1XHpjKo7vTjiI1wabalO98kgszWLAjWe6CLHOr3az9kOdas";
 },*/


#import "Song.h"

@implementation Song

-(Song*)initWithJSON:(id)json
{
    if (self = [super init]) {
        _artist = [json objectForKey:@"artist"];
        _duration = [[json objectForKey:@"duration"] intValue];
        _genreId = [[json objectForKey:@"genre_id"] intValue];
        _songId = [[json objectForKey:@"id"] intValue];
        _lyricsId = [[json objectForKey:@"lyrics_id"] intValue];
        _ownerId = [[json objectForKey:@"owner_id"] intValue];
        _title = [json objectForKey:@"title"];
        _URLString = [json objectForKey:@"url"];
        _URL = [NSURL URLWithString:[json objectForKey:@"url"]];
        return self;
    }
    return nil;
}

@end
