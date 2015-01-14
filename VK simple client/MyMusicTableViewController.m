//
//  MyMusicTableViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 09.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "MyMusicTableViewController.h"
#import "PlayerViewController.h"
#import "Song.h"
#import "Playlist.h"
#import "SongCell.h"
#define LOADED_COUNT 100


@interface MyMusicTableViewController ()

@end

static NSString* currentUserId;
static int audioTotalCount;
static int pagesTotalCount;
static UILabel *notLoadingLabel;

@implementation MyMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"VK_TOKEN"]) {
        [self performSegueWithIdentifier:@"toLoginSegue" sender:self];
    }
    self.page = 0;
    self.isLoading = NO;
    
    notLoadingLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    [notLoadingLabel setTextAlignment:NSTextAlignmentCenter];
    [notLoadingLabel setText:@"Произошла ошибка загрузки"];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    [[[VKApi users] get] executeWithResultBlock:^(VKResponse *response) {
        currentUserId = [[response.json objectAtIndex:0] objectForKey:@"id"];
        [self loadMusicForPage:self.page];
    } errorBlock:^(NSError *error) {
        
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - easy instantiation

-(NSMutableArray *)musicArray{
    if (!_musicArray) {
        _musicArray = [[NSMutableArray alloc] init];
    }
    return _musicArray;
}

#pragma mark - data loading

-(void)loadMusicForPage:(int)page
{
    if (!self.isLoading) {
        
        NSNumber* offset = [NSNumber numberWithInt:(page*LOADED_COUNT)];
        
        VKRequest * audioReq = [VKApi requestWithMethod:@"audio.get" andParameters:@{VK_API_USER_ID : currentUserId, VK_API_COUNT : @(LOADED_COUNT),VK_API_OFFSET : offset} andHttpMethod:@"GET"];
        [audioReq executeWithResultBlock:^(VKResponse *response)
        {
            audioTotalCount = [[response.json objectForKey:VK_API_COUNT] intValue];
            pagesTotalCount = ceilf((float)audioTotalCount/LOADED_COUNT); //количество страниц
            for (NSDictionary* songDict in [response.json objectForKey:@"items"])
            {
                Song* song = [[Song alloc] initWithJSON:songDict];
                [self.musicArray addObject:song];
                [notLoadingLabel removeFromSuperview];
            }
            [self.tableView reloadData];
        } errorBlock:^(NSError *error) {
            NSLog(@"ERROR! %@",error.description);
            [self.view addSubview:notLoadingLabel];
        }];
    }
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.page+1 >= pagesTotalCount)
        return self.musicArray.count;
    else
        return self.musicArray.count+1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.musicArray.count)
    {
        UITableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"refresh" forIndexPath:indexPath];
        return cell;
    }
    else
    {
        SongCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"songCell" forIndexPath:indexPath];
        cell.title.text = ((Song*)[self.musicArray objectAtIndex:indexPath.row]).title;
        cell.subtitle.text = ((Song*)[self.musicArray objectAtIndex:indexPath.row]).artist;
        int duration = ((Song*)[self.musicArray objectAtIndex:indexPath.row]).duration;
        cell.length.text = [NSString stringWithFormat:@"%i:%02i",duration/60,duration%60];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == self.musicArray.count) {
//        return 44;
//    }
//    return 53;
//}

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqual:@"refresh"])
    { //Загрузить еще...
        if (self.page+1 < pagesTotalCount)
        {
            self.page++;
            [self loadMusicForPage:self.page];
        }
    } else
    {
        [Playlist sharedInstance].array = self.musicArray;
        [self performSegueWithIdentifier:@"musicListToPlayerSegue" sender:indexPath];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[PlayerViewController class]]) {
        if ([sender isKindOfClass:[NSIndexPath class]])
        {
            PlayerViewController *destination = segue.destinationViewController;
            [destination addToPlaylist:self.musicArray andPlayTrack:(int)[sender row]];
        }
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = LOADED_COUNT;
    if(y > h + reload_distance)
    {
        if ([self.musicArray count]%LOADED_COUNT == 0 && !self.isLoading) {
            self.page++;
            [self loadMusicForPage:self.page];
        }
    }
}
*/


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



@end
