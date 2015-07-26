//
//  PostViewController.m
//  YikYak
//
//  Created by Sergio Puleri on 7/12/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

#import "PostViewController.h"

@interface PostViewController ()
- (void)alert;
@end

@implementation PostViewController

CLLocationManager *postLocationManager;

- (void)alert {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops, something went wrong!" message:@"Please enable location in the settings menu" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok!!" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSLog(@"Goin to settings");
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettings];
    }];
    
    [alert addAction:settings];
    [alert addAction:action];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reset = false;
    self.postView.selectedRange = NSMakeRange(0, 0);
    self.postView.delegate = self;
    [self.postView becomeFirstResponder];
    
    postLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    postLocationManager.delegate = self;
    [postLocationManager requestWhenInUseAuthorization];
    [postLocationManager startUpdatingLocation];
}

- (void)postLocationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [postLocationManager stopUpdatingLocation];
    if(locations.count > 0) {
        CLLocation *myLocation = locations[0];
        NSLog(@"Users lat is: %f", myLocation.coordinate.latitude);
        NSLog(@"Users long is: %f", myLocation.coordinate.longitude);
        // Assigning current location :-)
        self.currLocation = myLocation.coordinate;
    } else {
        [self alert];
    }
}

- (void)postLocationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)postPressed:(id)sender {
    
    if (CLLocationCoordinate2DIsValid(self.currLocation)) {
        PFObject *postObj = [PFObject objectWithClassName:@"Yak"];
        
        [postObj setObject:self.postView.text forKey:@"yak"];
        [postObj setObject:@0 forKey:@"count"];
        [postObj setObject:@0 forKey:@"replies"];
        PFGeoPoint *postLoc = [PFGeoPoint geoPointWithLatitude:self.currLocation.latitude longitude:self.currLocation.longitude];
        [postObj setObject:postLoc forKey:@"location"];
        [postObj saveInBackground];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        [self alert];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.reset == false) {
        //idk why we doin this
        self.postView.text = [NSString stringWithFormat:@"%c", [self.postView.text characterAtIndex:0]];
        self.reset = true;
    }
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
