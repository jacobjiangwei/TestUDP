//
//  ViewController.m
//  TestBluetooth
//
//  Created by Jiang Jacob on 6/18/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import "ViewController.h"
#import "MultiPeerManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(id)sender {
    [[MultiPeerManager manager] refreshNetwork];
}
@end
