//
//  TestTableViewController.h
//  testUDP
//
//  Created by Jiang Jacob on 6/18/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewController : UITableViewController
{
    NSMutableArray *chatMessage;
}

- (IBAction)sendOneMessage:(id)sender;



@end
