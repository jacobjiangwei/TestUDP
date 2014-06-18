//
//  UdpManager.m
//  ChatWiz
//
//  Created by Jiang Jacob on 6/13/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import "UdpManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if_var.h>
#include <net/if.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>

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
    NSLog(@"Udp server started on IP: %@ port %hu",[self localIPAddress] ,[udpSocket localPort]);
}

-(void)sendGroupMessage:(NSString *)text
{
    
}

-(void)sendMessage:(NSString *)text toHost:(NSString *)host port:(NSInteger)port
{
    NSData *textData=[text dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:textData toHost:host port:port withTimeout:-1 tag:0];
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


- (NSString *)localIPAddress
{
    /*
     struct hostent *host = gethostbyname([[self hostname] UTF8String]);
     if (!host) {herror("resolv"); return nil;}
     struct in_addr **list = (struct in_addr **)host->h_addr_list;
     //    NSLog(@"本地IP :%@",[NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding]);
     return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
     */
    NSArray *ipArray=[self localIPAddresses];
    for (NSString *ipAddr in ipArray) {
        if ([self isValidatIP:ipAddr]) {
            return ipAddr;
        }
    }
    //第一种方法还不行，就第二种继续
    struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    //    NSLog(@"本地IP :%@",[NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding]);
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    
    return nil;
}

-(BOOL)isValidatIP:(NSString *)ipAddress{
    
    NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:ipAddress];
    
}

- (NSArray *)localIPAddresses
{
    NSMutableArray *ipAddresses = [NSMutableArray array] ;
    struct ifaddrs *allInterfaces;
    
    // Get list of all interfaces on the local machine:
    if (getifaddrs(&allInterfaces) == 0)
    {
        struct ifaddrs *interface;
        // For each interface ...
        for (interface = allInterfaces; interface != NULL; interface = interface->ifa_next)
        {
            unsigned int flags = interface->ifa_flags;
            struct sockaddr *addr = interface->ifa_addr;
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if ((flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING)) {
                if (addr->sa_family == AF_INET ) {
                    
                    if ([[NSString stringWithUTF8String:interface->ifa_name] isEqualToString:@"en0"]) {
                        // Convert interface address to a human readable string:
                        char host[NI_MAXHOST];
                        getnameinfo(addr, addr->sa_len, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
                        
                        [ipAddresses addObject:[[NSString alloc] initWithUTF8String:host]];
                    }
                }
            }
        }
        freeifaddrs(allInterfaces);
    }
    return ipAddresses;
}

// return IP Address
- (NSString *)hostname
{
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if !TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#else
    return [NSString stringWithFormat:@"%s", baseHostName];
#endif
}



@end
