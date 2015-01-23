//
//  VSLyricsView.h
//  VK simple client
//
//  Created by Виктор Стариков on 21.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSLyricsDownloader.h"


@interface VSLyricsView : UIView <VSLyricsDownloaderDelegate>

-(void)getLyricsForTitle:(NSString*)title artist:(NSString*)artist;

@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UITextView* textView;
@property (strong, nonatomic) UIFont* font;
@property (strong, nonatomic) UIFont* highlightedTextFont;
@property (strong, nonatomic) UIColor* textColor;
@property (strong, nonatomic) UIColor* highlightedTextColor;

@end
