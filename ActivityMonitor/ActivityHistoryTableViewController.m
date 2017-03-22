//
//  ActivityHistoryTableViewController.m
//  ActivityMonitor
//
//  Created by Cuong Ta on 8/17/16.
//  Copyright © 2016 cuong. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "ActivityHistoryTableViewController.h"

@interface ActivityHistoryTableViewController ()

@property (nonatomic, strong) CMMotionActivityManager *motionActivityMgr;
@property (nonatomic, strong) CMPedometer *pedometer;
@property (nonatomic, strong) NSMutableArray *activities;

@end

@implementation ActivityHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _motionActivityMgr = [[CMMotionActivityManager alloc] init];
    _pedometer = [[CMPedometer alloc] init];
    
    _activities = [[NSMutableArray alloc] init];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    if ([[self class] checkAvailability]) {
        [self checkAuthorization:^(bool authorized) {
            [self fetchActivityHistory];
        }];
    }
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)]];
}

-(void)refresh{
    [self fetchActivityHistory];
}

-(void)fetchActivityHistory{
    NSDate *now = [NSDate date];
    NSDate *eightHoursAgo = [now dateByAddingTimeInterval:-24*60*60];
    [_motionActivityMgr queryActivityStartingFromDate:eightHoursAgo toDate:now toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray<CMMotionActivity *> * _Nullable activities, NSError * _Nullable error) {
        NSLog(@"activities = %@", activities);
        
        NSMutableArray *mutableActivities = [[NSMutableArray alloc] initWithCapacity:activities.count];
        [activities enumerateObjectsUsingBlock:^(CMMotionActivity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
        }];
        
        _activities = [activities mutableCopy];
        [self.tableView reloadData];
    }];
}

+(bool)checkAvailability{
    static dispatch_once_t onceToken;
    static bool available = true;
    dispatch_once(&onceToken, ^{
        if ([CMMotionActivityManager isActivityAvailable] == NO) {
            NSLog(@"isActivityAvailable = no");
            available = NO;
        }
        if ([CMPedometer isStepCountingAvailable] == 0) {
            NSLog(@"isActivityAvailable = no");
            available = NO;
        }
    });
    return available;
}

-(void)checkAuthorization:(void (^)(bool authorized))authorizationCheckCompleteHandler{
    NSDate *now = [NSDate date];
    [_pedometer queryPedometerDataFromDate:now toDate:now withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            authorizationCheckCompleteHandler(!error || error.code != CMErrorMotionActivityNotAuthorized);
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    CMMotionActivity *activity = [_activities objectAtIndex:indexPath.row];
    if (activity.automotive) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - automotive 🚗",activity.startDate];
    } else if (activity.walking) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - walking 🚶",activity.startDate];
    } else if (activity.running) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - running 🏃",activity.startDate];
    } else if (activity.stationary) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - stationary 🛑",activity.startDate];
    } else if (activity.unknown) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - unknown ",activity.startDate];
    }
    
    return cell;
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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
