//
//  VSLyricsDownloader.h
//  VK simple client
//
//  Created by Виктор Стариков on 20.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>



@protocol VSLyricsDownloaderDelegate <NSObject>

-(void)didRecieveLRC:(NSArray*)lyricsArray withOffset:(float)offset;
-(void)didRecievePlainTextLyrics:(NSString*)lyrics;
-(void)didNotRecieveLyrics;

@end

@interface VSLyricsDownloader : NSObject <NSXMLParserDelegate>

+(VSLyricsDownloader *) sharedInstance;

@property (weak, nonatomic) id<VSLyricsDownloaderDelegate> delegate;
@property (strong, nonatomic) NSString* plainTextLyrics;
@property (strong, nonatomic) NSArray* LRCLyrics;
@property (nonatomic) float offset;

-(void)getLRCForTitle:(NSString*)title artist:(NSString*)artist;


@end
