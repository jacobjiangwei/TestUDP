//
//  UdpManager.h
//  ChatWiz
//
//  Created by Jiang Jacob on 6/13/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"


@interface UdpManager : NSObject
{
    dispatch_queue_t   udpQuene;
    GCDAsyncUdpSocket   *udpSocket;
}
+(UdpManager *)manager;

- (NSString *)localIPAddress;

-(void)startServer;
-(void)stopServer;
-(void)joinMulticast;
-(void)sendGroupMessage:(NSData *)data;
-(void)sendMessage:(NSData *)data toHost:(NSString *)host port:(NSInteger)port;

@end
