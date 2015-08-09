//
//  TableViewController.m
//  YikYak
//
//  Created by Sergio Puleri on 7/12/15.
//  Copyright (c) 2015 Sergio Puleri. All rights reserved.
//

//@@@SUPER GOOD STUFF ABOUT PARSE https://parse.com/docs/ios/guide#ui-tables/iOS @@@@@@@@@


#import "TableViewController.h"
#import "TableViewCell.h"
#import "DetailViewController.h"
#import "Utility.h"


@interface TableViewController ()
//private things are declared here!
- (void)alert:(NSString *)message;
@end

@implementation TableViewController




- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Yak";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"yak";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 200;
    }
    return self;
}


- (void)alert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops, something went wrong!" message:message preferredStyle:UIAlertControllerStyleAlert];
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
    
    self.locationManager = [[CLLocationManager alloc] init];
    // dont need to initialze curr location
    //currLocation  = [[CLLocationCoordinate2D alloc ] init];

    
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.locationManager.desiredAccuracy = 1000;
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// implementing method from locationprotocol for failing
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // calling my private method alert to display alerts
    [self alert:@"Cannot fetch ur location nub"];
}

//overriding to construct a custom PFQuery that should be used to get objects for the table.
- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Yak"];
    
    CLLocationCoordinate2D queryLoc = self.currLocation;
    
    PFGeoPoint *geoPoint;
    bool firstLoad;
    // if initial loading
    //if (queryLoc == NULL){
      //   geoPoint = [PFGeoPoint geoPointWithLatitude:0.0 longitude:0.0];
        //firstLoad = true;
    //} else {
        // get actual location
        geoPoint = [PFGeoPoint geoPointWithLatitude:queryLoc.latitude longitude:queryLoc.longitude];
    //}
    
    
    if(firstLoad || CLLocationCoordinate2DIsValid(queryLoc)){
        [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:(10)];
        query.limit = 200;
        [query orderByDescending:@"createdAt"];
    } else {
        // Decide how app should react if has no location
        // return 10 most recent
        query.limit = 10;
        [query orderByDescending:@"createdAt"];
    }
    
    return query;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    
    if(locations.count > 0) {
        CLLocation *myLocation = locations[0];
        NSLog(@"Users lat is: %f", myLocation.coordinate.latitude);
        NSLog(@"Users long is: %f", myLocation.coordinate.longitude);
        // Assigning current location :-)
        self.currLocation = myLocation.coordinate;
        //reloading bcs first load was with currlocation == 0
        //cuz PFTableView loads in [super viewDidLoad]
        //so i dont have a location yet
        [self loadObjects];
    } else {
        [self alert:@"Couldnt get ur location..."];
    }
}

#pragma mark - Table view data source


- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *obj = nil;
    
    if(indexPath.row < self.objects.count) {
        obj = self.objects[indexPath.row];
    }
    
    return obj;
    
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    
    cell.yakText.text = [object valueForKey:@"yak"];
    cell.yakText.numberOfLines = 0;
    
    // Was screwing up bcs count is an NSNumber, where count.text is wanting NSString
    cell.count.text = [[object valueForKey:@"count"] stringValue];
    
    cell.time.text = [NSString stringWithFormat:@"%@", [Utility stringForTimeIntervalSinceCreated:[object valueForKey:@"createdAt"]]];
    cell.replies.text = [NSString stringWithFormat:@"%@%@", [object valueForKey:@"replies"] , @" replies" ];
    
    return cell;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%@%i", @"You selected row! ", indexPath.row);
//    
//    //TableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    self.selectedYak = [self objectAtIndexPath:indexPath];
//    [self performSegueWithIdentifier:@"yakComments" sender:self];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if( [segue.identifier isEqualToString:@"yakDetails"]) {
        // Capture the object (e.g. exam) the user has selected from the list
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        // Set destination view controller to DetailViewController to avoid the NavigationViewController in the middle (if you have it embedded into a navigation controller, if not ignore that part)
        //UINavigationController *nav = [segue destinationViewController];
        DetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.yak = object;
    }
    
    
}


- (IBAction)topButton:(id)sender {
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    PFObject *object = [self objectAtIndexPath:hitIndex];
    [object incrementKey:@"count"];
    [object saveInBackground];
    [self.tableView reloadData];
    
    NSLog(@"Top Index Path %@", [@(hitIndex.row) stringValue]);
    
}

- (IBAction)bottomButton:(id)sender {
    
    CGPoint hitPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath* hitIndex = [self.tableView indexPathForRowAtPoint:hitPoint];
    
    PFObject *object = [self objectAtIndexPath:hitIndex];
    [object incrementKey:@"count" byAmount:@-1];
    [object saveInBackground];
    [self.tableView reloadData];
    
    NSLog(@"Bottom Index Path %@", [@(hitIndex.row) stringValue]);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
