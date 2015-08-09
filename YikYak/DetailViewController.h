//
//  DetailViewController.h
//  YikYak
//
//  Created by Sergio Puleri on 7/26/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
//IB Outlets
@property (weak, nonatomic) IBOutlet UILabel *yakText;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) PFObject *yak;
@property (strong, nonatomic) UITextView *commentView;
@property (strong, nonatomic) UIView *footerView;
@property (nonatomic) CGFloat *contentHeight;
@property (strong, nonatomic) NSArray *comments;



@end
