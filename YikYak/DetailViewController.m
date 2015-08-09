//
//  DetailViewController.m
//  YikYak
//
//  Created by Sergio Puleri on 7/26/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import "DetailViewController.h"
#import "CommentTableViewTableViewCell.h"
#import "Utility.h"

@interface DetailViewController ()
@property CGFloat FOOTERHEIGHT;
- (void)keyBoardWillShow:(NSNotification*)notifcation;
- (void)keyBoardWillHide:(NSNotification*)notifcation;
- (void)reply;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    // Do any additional setup after loading the view.
    self.contentHeight = 0;
    self.FOOTERHEIGHT = 50;
    /* Setup the datasource delegate */
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
     /* Setup the keyboard notifications */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    /* Setup the contentInsets */
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    /* Make sure the content doesn't go below tabbar/navbar */
    self.extendedLayoutIncludesOpaqueBars = true;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    /* Setup Map */
    PFGeoPoint *geo = [self.yak objectForKey:@"location"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geo.latitude, geo.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1500, 1500);
    
    [self.mapView setRegion:region animated:true];
    self.mapView.showsUserLocation = true;

    
    
    if([self.yak objectForKey:@"comments"] != nil) {
        self.comments = [NSArray arrayWithArray:[self.yak objectForKey:@"comments"]];
    }
    NSLog(@"%@", self.yak);
    NSLog(@"%@", [self.yak objectForKey:@"yak"]);
    self.yakText.text = [self.yak objectForKey:@"yak"];
    
    NSDate *postTime = [self.yak createdAt];
    //NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    //NSString *stringPostTime = [dateFormatter stringFromDate: postTime];
    NSString *stringPostTime = [Utility stringForTimeIntervalSinceCreated:postTime];
    
    NSLog(@"%@%@", @"was posted @: ", stringPostTime);
    self.timeLabel.text = stringPostTime;

    
}
- (void)keyBoardWillShow:(NSNotification *)notifcation {
    NSDictionary *info = notifcation.userInfo;
    NSValue *keyboardSizeValue = [info objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    CGRect keyboardSizeRect = keyboardSizeValue.CGRectValue;
    
    CGFloat keyboardHeight = keyboardSizeRect.size.height - 40;
    NSNumber *animationDurationNumber = [info objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
    //idk what this line does.. never used.
    CGFloat animationDuration = animationDurationNumber.doubleValue;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyBoardWillHide:(NSNotification *)notifcation {
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.comments.count > 0){
        return self.comments.count;
    }
    else return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        CommentTableViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    cell.commentText.text = self.comments[indexPath.row];
    [cell.commentText sizeToFit];
    cell.commentText.numberOfLines = 0;    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.footerView != nil) {
        return self.footerView.bounds.size.height;
    }
    else return _FOOTERHEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, _FOOTERHEIGHT)];
    NSLog(@"%@%f", @"Table view bounds width is: ", tableView.bounds.size.width );
    self.footerView.backgroundColor = [UIColor colorWithRed:243.0/255 green:243.0/255 blue:243.0/255 alpha:1];
    self.commentView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, tableView.bounds.size.width - 360, 40)];
    self.commentView.backgroundColor = [UIColor whiteColor];
    self.commentView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.commentView.layer.cornerRadius = 2;
    self.commentView.scrollsToTop = true;
    
    [self.footerView addSubview:self.commentView];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 345, 10, 60, 30)];
    [button setTitle:@"Reply" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:155.0/255 green:189.0/255 blue:113.0/255 alpha:1];
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:button];
    self.commentView.delegate = self;
    
    return self.footerView;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (self.contentHeight == 0){
        // might not work. dereffing the pointer, shud work tho
        CGFloat tmp = self.commentView.contentSize.height;
        self.contentHeight = &tmp;
    }
    
    if(self.commentView.contentSize.height != *self.contentHeight &&
       self.commentView.contentSize.height > self.footerView.bounds.size.height) {
        
        [UIView animateWithDuration:0.2 animations:^{
            UIView *myView = self.footerView;
            NSLog(@"%f", self.commentView.contentSize.height);
            NSLog(@"%f", self.commentView.font.lineHeight);
            
            CGFloat newHeight = self.commentView.font.lineHeight;
            CGRect myFrame = CGRectMake(CGRectGetMinX(myView.frame), CGRectGetMinY(myView.frame) - newHeight, myView.bounds.size.width, newHeight + myView.bounds.size.height);
            myView.frame = myFrame;
            
            UITextView *myComm = self.commentView;
            CGFloat newCommHeight = self.commentView.contentSize.height;
            CGRect myCommFrame = CGRectMake(CGRectGetMinX(myComm.frame), CGRectGetMinY(myComm.frame), myComm.bounds.size.width, newCommHeight);
            myComm.frame = myCommFrame;
            
            self.commentView = myComm;
            self.footerView = myView;
            
            for (UIView *item in self.footerView.subviews) {
                if ([item isKindOfClass:UIButton.self]) {
                    UIButton *butt = (UIButton *) item;
                    CGFloat newY = self.footerView.bounds.size.height/2 - butt.bounds.size.height-2;
                    CGRect buttonFrame = CGRectMake(CGRectGetMinX(butt.frame), newY, butt.bounds.size.width, butt.bounds.size.height);
                    butt.frame = buttonFrame;
                }
            }
            
        }];
        
        NSLog(@"%@", NSStringFromCGRect(self.footerView.frame) );
        NSLog(@"%@", NSStringFromCGRect(self.commentView.frame));
        CGFloat tmp2 = self.commentView.contentSize.height;
        self.contentHeight = &tmp2;
    }
    
    
}


- (void)reply{
    
    [self.yak addObject:self.commentView.text forKey:@"comments"];
    
    if([self.commentView hasText]) {
        
        NSString *tmptxt = self.commentView.text;
        NSMutableArray *tmparr = [[NSMutableArray alloc] initWithArray:self.comments];
        
        [tmparr addObject:tmptxt];
        
        self.comments = [NSArray arrayWithArray:tmparr];
        //[tmparr release];
    }
    self.commentView.text = @"";
    NSLog(@"%@%lu", @"There are this many comments: ", (unsigned long)self.comments.count);
    
    [self.yak setObject:[NSNumber numberWithInteger:self.comments.count]forKey:@"replies"];
    [self.yak saveInBackground];

    [self.commentView resignFirstResponder];
    [self.tableView reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
