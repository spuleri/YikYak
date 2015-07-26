//
//  TableViewCell.h
//  YikYak
//
//  Created by Sergio Puleri on 7/12/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface TableViewCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *yakText;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UILabel *replies;

@end
