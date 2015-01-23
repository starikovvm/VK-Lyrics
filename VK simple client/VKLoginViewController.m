//
//  VKLoginViewController.m
//  VK simple client
//
//  Created by Виктор Стариков on 12.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import "VKLoginViewController.h"
//#import "PlayController.h"
#import "VSLyricsDownloader.h"

@interface VKLoginViewController ()

@end

static NSArray* SCOPE = nil;

@implementation VKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [VKSdk initializeWithDelegate:self andAppId:@"4717791"];
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO];      //, VK_PER_PHOTOS, VK_PER_EMAIL, VK_PER_MESSAGES];
    if ([VKSdk wakeUpSession])
    {
        [self startWorking];
    }
}

-(void)startWorking
{
    [self performSegueWithIdentifier:@"fromLoginSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logIn:(UIButton *)sender {
    [VKSdk authorize:SCOPE];
}



@end
