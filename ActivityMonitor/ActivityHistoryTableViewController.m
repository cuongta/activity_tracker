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
//        NSLog(@"activities = %@", activities);
        
        // sort descending order
        NSArray *sorted = [NSArray arrayWithArray:[activities sortedArrayUsingComparator:^NSComparisonResult(CMMotionActivity *obj1, CMMotionActivity *obj2) {
            NSTimeInterval t1 = [obj1.startDate timeIntervalSince1970];
            NSTimeInterval t2 = [obj2.startDate timeIntervalSince1970];
            return (t1 < t2);
        }]];
        
        _activities = [sorted mutableCopy];
//        NSLog(@"activities = %@", activities);
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    CMMotionActivity *activity = [_activities objectAtIndex:indexPath.row];
    
//    NSISO8601DateFormatter *fmt = [[NSISO8601DateFormatter alloc] init];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    [fmt setTimeZone:[NSTimeZone localTimeZone]];
    NSString *localTime = [fmt stringFromDate:activity.startDate];
    
    if (activity.automotive) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - automotive 🚗",localTime];
    } else if (activity.walking) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - walking 🚶",localTime];
    } else if (activity.running) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - running 🏃",localTime];
    } else if (activity.stationary) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - stationary 🛑",localTime];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - unknown ",localTime];
    }
    
    return cell;
}

@end
