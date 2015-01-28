//
//  VSLyricsView.h
//  VK simple client
//
//  Created by Виктор Стариков on 21.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSLyricsDownloader.h"

@protocol VSLyricsViewDelegate <NSObject>

-(NSTimeInterval)currentTime;

@end


@interface VSLyricsView : UIView <VSLyricsDownloaderDelegate>

-(void)getLyricsForTitle:(NSString*)title artist:(NSString*)artist;

@property (weak, nonatomic) id<VSLyricsViewDelegate> delegate;
@property (strong, nonatomic) UITextView* textView;
@property (strong, nonatomic) UIFont* font;
@property (strong, nonatomic) UIFont* LRCTextFont;
@property (strong, nonatomic) UIColor* textColor;
@property (strong, nonatomic) UIColor* LRCTextColor;
@property (strong, nonatomic) NSArray* LRCArray;
@property (nonatomic) NSTimeInterval* offset;

@end
