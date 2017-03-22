//
//  ViewController.m
//  ActivityMonitor
//
//  Created by Cuong Ta on 8/17/16.
//  Copyright © 2016 cuong. All rights reserved.
//

#import "ViewController.h"
#import "FeaturesTableViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UINavigationController *navNC;

@property (nonatomic, strong) FeaturesTableViewController *featureVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
//    _featureVC = [[FeaturesTableViewController alloc] init];
//    _navNC = [[UINavigationController alloc] initWithRootViewController:_featureVC];
//    _featureVC.title = @"Activity Tracker";
//    [self.view addSubview:_navNC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
