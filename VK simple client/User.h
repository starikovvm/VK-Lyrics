//
//  User.h
//  VK simple client
//
//  Created by Виктор Стариков on 06.01.15.
//  Copyright (c) 2015 Viktor Starikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) int ID;

@property (strong,nonatomic) NSString* firstName;
@property (strong,nonatomic) NSString* secondName;
@property (strong,nonatomic) NSString* imageURL;
@property (nonatomic) int sex;


@end
