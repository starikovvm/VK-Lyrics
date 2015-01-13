//
//  SecondViewController.h
//  VK simple client
//
//  Created by Виктор Стариков on 06.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SecondViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *musicArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (nonatomic) float isLoading;
@property (nonatomic) int page;

@end

