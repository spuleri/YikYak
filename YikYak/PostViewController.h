//
//  PostViewController.h
//  YikYak
//
//  Created by Sergio Puleri on 7/12/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface PostViewController : UIViewController <UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D currLocation;
@property (nonatomic) BOOL reset;
@property (weak, nonatomic) IBOutlet UITextView *postView;


@end
