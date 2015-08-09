//
//  Utility.m
//  YikYak
//
//  Created by Sergio Puleri on 8/9/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import "Utility.h"

@implementation Utility


// How to get relative time: eg. "5m ago", "3 days ago"
//copypasted from: http://stackoverflow.com/questions/902950/iphone-convert-date-string-to-a-relative-time-stamp
+ (NSString *)stringForTimeIntervalSinceCreated:(NSDate *)dateTime
{
    NSDictionary *timeScale = @{@"second":@1,
                                @"minute":@60,
                                @"hour":@3600,
                                @"day":@86400,
                                @"week":@605800,
                                @"month":@2629743,
                                @"year":@31556926};
    NSString *scale;
    int timeAgo = 0-(int)[dateTime timeIntervalSinceNow];
    if (timeAgo < 60) {
        scale = @"second";
    } else if (timeAgo < 3600) {
        scale = @"minute";
    } else if (timeAgo < 86400) {
        scale = @"hour";
    } else if (timeAgo < 605800) {
        scale = @"day";
    } else if (timeAgo < 2629743) {
        scale = @"week";
    } else if (timeAgo < 31556926) {
        scale = @"month";
    } else {
        scale = @"year";
    }
    
    timeAgo = timeAgo/[[timeScale objectForKey:scale] integerValue];
    NSString *s = @"";
    if (timeAgo > 1) {
        s = @"s";
    }
    return [NSString stringWithFormat:@"%d %@%@ ago", timeAgo, scale, s];
}

@end
