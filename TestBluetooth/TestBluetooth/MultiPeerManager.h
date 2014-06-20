//
//  MultiPeerManager.h
//  OpenP2P
//
//  Created by Jacob Jiang on 2/10/14.
//  Copyright (c) 2014 Jacob Jiangwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MultipeerConnectivity/MCPeerID.h>

#define NOTIFICATION_RADER_TOOTH @"RadarScaningWithTooth"
#define MULTIPEER_SERVICE_TYPE @"openp2p-join"
/*
@protocol PeerSendMessageDelegate <NSObject>
-(void)peerSendMessageSuccess:(ChatMessages *)message;
-(void)peerSendMessageFailed:(ChatMessages *)message;
@end
*/
@interface MultiPeerManager : NSObject<MCNearbyServiceAdvertiserDelegate,MCNearbyServiceBrowserDelegate,MCSessionDelegate,CBCentralManagerDelegate>
{
    NSDate                  *lastTimeReload;

}
@property (nonatomic,strong)    MCNearbyServiceAdvertiser   *nearbyAdvertiser;
@property (nonatomic,strong)    MCNearbyServiceBrowser      *nearbyBrowser;

@property (nonatomic,strong)    MCPeerID                    *myPeerID;
@property (nonatomic,strong)    MCSession                   *nearbySession;
@property (nonatomic,strong)    NSMutableArray              *connectingPeers;
@property (nonatomic,strong)    CBCentralManager            *bluetoothManager;


+(MultiPeerManager *)manager;

//@property (nonatomic,unsafe_unretained) id <PeerSendMessageDelegate>              messageDelegate;

- (void)detectBluetooth;
- (void)startServices;
- (void)stopServices;
-(void)refreshNetwork;
-(void)backgroundMode;

//单发消息，标志位是NO；群发消息是YES，无需要遍历friend，一键群发
//-(void)sendMessage:(ChatMessages *)message;

-(void)sendMessageToAll:(NSString *)content
              type:(NSString *)type;


@end
