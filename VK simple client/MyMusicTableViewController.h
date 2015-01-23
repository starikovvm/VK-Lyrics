//
//  MyMusicTableViewController.h
//  VK simple client
//
//  Created by Виктор Стариков on 09.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKSdk.h"


@interface MyMusicTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong,nonatomic) NSMutableArray *musicArray;
@property (nonatomic) float isLoading;
@property (nonatomic) int page;
@property (nonatomic) float isSearching;
@property (strong,nonatomic) NSString* searchQuery;

@end
