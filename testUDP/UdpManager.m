//
//  UdpManager.m
//  ChatWiz
//
//  Created by Jiang Jacob on 6/13/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import "UdpManager.h"

static UdpManager * _sharedInstance=nil;

@implementation UdpManager

+(UdpManager *)manager
{
    if (!_sharedInstance) {
        _sharedInstance=[[UdpManager alloc]init];
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        udpQuene=dispatch_queue_create("udpQueue", NULL);
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:udpQuene];
        udpSocket.delegate=self;
    }
    return self;
}

-(void)startServer
{
    NSError *error = nil;
    
    if (![udpSocket bindToPort:33333 error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        [udpSocket close];
        NSLog(@"Error starting server (recv): %@", error);
        return;
    }
    NSLog(@"Udp server started on port %hu", [udpSocket localPort]);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"didNotConnect %d",error.code);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag %ld",tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag %ld error %d",tag,error.code);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSLog(@"didReceiveData ");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose ERROR %d ",error.code);
}


@end
