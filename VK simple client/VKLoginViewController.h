//
//  VKLoginViewController.h
//  VK simple client
//
//  Created by Виктор Стариков on 12.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKSdk.h"

@interface VKLoginViewController : UIViewController <VKSdkDelegate>
- (IBAction)logIn:(UIButton *)sender;

@end
