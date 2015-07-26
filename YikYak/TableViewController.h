//
//  TableViewController.h
//  YikYak
//
//  Created by Sergio Puleri on 7/12/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>



@interface TableViewController : PFQueryTableViewController <CLLocationManagerDelegate> //location manager is a protocol

@property (nonatomic, strong) NSArray *yaks;
@property (nonatomic) CLLocationCoordinate2D currLocation;

@end
