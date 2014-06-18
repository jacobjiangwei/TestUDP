//
//  AppDelegate.h
//  testUDP
//
//  Created by Jiang Jacob on 6/18/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic,assign) BOOL isBackground;
@property (strong, nonatomic) UIWindow *window;

@end
