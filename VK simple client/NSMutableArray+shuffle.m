//
//  NSMutableArray+shuffle.m
//  
//
//  Created by Виктор Стариков on 23.01.15.
//
//

#import "NSMutableArray+shuffle.h"

@implementation NSMutableArray (shuffle)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end
