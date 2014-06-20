//
//  MultiPeerManager.m
//  OpenP2P
//
//  Created by Jacob Jiang on 2/10/14.
//  Copyright (c) 2014 Jacob Jiangwei. All rights reserved.
//

#import "MultiPeerManager.h"
//#import "LocalNotification.h"
#import "AppDelegate.h"
//#import "ChatMessages.h"
static MultiPeerManager * _sharedInstance=nil;

@implementation MultiPeerManager

+(MultiPeerManager *)manager
{
    if (!_sharedInstance) {
        _sharedInstance=[[MultiPeerManager alloc]init];
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        //MultiPeers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationWillTerminate
{
    [self stopServices];
}

- (void)applicationDidEnterBackground
{
    
}

- (void)applicationWillEnterForeground
{
    [self refreshNetwork];
}

-(void)refreshNetwork
{
//    if ([[NSDate date] timeIntervalSinceDate:lastTimeReload]<15) {
//        NSLog(@"MultiPeer刷新太快");
//        return;
//    }
//    lastTimeReload=[NSDate date];
    [self stopServices];
//    [self detectBluetooth];
    [self startServices];
}
/*
- (void)detectBluetooth
{
    self.bluetoothManager=nil;
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:NO]}];
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(central.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use.";  break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    NSLog(@"%@",stateString);
    if (self.bluetoothManager.state==CBCentralManagerStatePoweredOn) {
        
    }
}
*/
- (void)setupSession
{
    NSLog(@"setupSession MultiPeer");
    // Create the session that peers will be invited/join into.

    if (_myPeerID) {
        _myPeerID=nil;
    }
    _myPeerID=[[MCPeerID alloc]initWithDisplayName:[UIDevice currentDevice].name];

    @try {
        if (_nearbySession) {
            [_nearbySession disconnect];
            _nearbySession.delegate = nil;
            _nearbySession=nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid _nearbySession dealloc ");
    }
    
    @try {
        _nearbySession=[[MCSession alloc]initWithPeer:_myPeerID];
        _nearbySession.delegate=self;
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid _nearbySession alloc ");
    }

    
    @try {
        if (_nearbyAdvertiser) {
            [_nearbyAdvertiser stopAdvertisingPeer];
            _nearbyAdvertiser.delegate=nil;
            _nearbyAdvertiser=nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid _nearbyAdvertiser dealloc ");
    }
    
    @try {
        _nearbyAdvertiser=[[MCNearbyServiceAdvertiser alloc]initWithPeer:_myPeerID discoveryInfo:nil serviceType:MULTIPEER_SERVICE_TYPE];
        _nearbyAdvertiser.delegate=self;
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid _nearbyAdvertiser alloc ");
    }
    
    @try {
        if (_nearbyBrowser) {
            [_nearbyBrowser stopBrowsingForPeers];
            _nearbyBrowser.delegate=nil;
            _nearbyBrowser=nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid _nearbyBrowser dealloc ");
    }
    
    @try {
        _nearbyBrowser=[[MCNearbyServiceBrowser alloc]initWithPeer:_myPeerID serviceType:MULTIPEER_SERVICE_TYPE];
        _nearbyBrowser.delegate=self;
    }
    @catch (NSException *exception) {
        NSLog(@"Invalid _nearbyBrowser alloc ");
    }

}

- (void)teardownSession
{
    NSLog(@"teardownSession MultiPeer");
    [_nearbySession disconnect];
}

- (void)startServices
{
    NSLog(@"开始MultiPeer搜索");
    [self setupSession];
    [_nearbyAdvertiser startAdvertisingPeer];
    [_nearbyBrowser startBrowsingForPeers];
}

-(void)backgroundMode
{
    NSLog(@"开始MultiPeer后台模式");
    [self setupSession];
    [_nearbyAdvertiser startAdvertisingPeer];
}

- (void)stopServices
{
    NSLog(@"关闭MultiPeer");
    [_nearbyAdvertiser stopAdvertisingPeer];
    [_nearbyBrowser stopBrowsingForPeers];
    [self teardownSession];
}

/*
-(void)sendMessage:(ChatMessages *)message
{
    NSArray *connectedPeers=self.nearbySession.connectedPeers;
    BOOL isConnected=NO;
    NSString *receiverUUID=message.friendSpeakTo.uuid;
    for (MCPeerID *peer in connectedPeers) {
        if ([peer.displayName isEqualToString:receiverUUID]) {
            isConnected=YES;
            
            NSDictionary *msgDic=nil;
            if ([message.type isEqualToString:@"image"]) {
                msgDic=@{@"message": @{@"content": [[ShareImageManager manager] base64StringForKey:message.content], @"type":message.type, @"uuid":[MyInfo manager].uuid}};
            }
            else
            {
                msgDic=@{@"message": @{@"content": message.content, @"type":message.type, @"uuid":[MyInfo manager].uuid}};
            }
            
            NSData *sendData=[NSJSONSerialization dataWithJSONObject:msgDic
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:nil];
            BOOL result=[self.nearbySession sendData:sendData toPeers:@[peer] withMode:MCSessionSendDataReliable error:nil];
            //修改数据发送成功状态
            message.isDelivered=@(result);
            NSError *error = nil;
            if (![[DataIO manager].managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            if (result) {
                if ([self.messageDelegate respondsToSelector:@selector(peerSendMessageSuccess:)]) {
                    [self.messageDelegate peerSendMessageSuccess:message];
                }
            }
            else
            {
                if ([self.messageDelegate respondsToSelector:@selector(peerSendMessageFailed:)]) {
                    [self.messageDelegate peerSendMessageFailed:message];
                }
            }
            break;
        }
    }
    
    //若压根没人连接着
    if (!isConnected) {
        //修改数据发送成功状态
        message.isDelivered=@(NO);
        NSError *error = nil;
        if (![[DataIO manager].managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if ([self.messageDelegate respondsToSelector:@selector(peerSendMessageFailed:)]) {
            [self.messageDelegate peerSendMessageFailed:message];
        }
    }
}

-(void)sendMessageToAll:(NSString *)content  type:(NSString *)type
{
    NSDictionary *msgDic=@{@"groupMessage": @{@"content": content, @"name":[MyInfo manager].name,@"type":type, @"uuid":[MyInfo manager].uuid}};
    NSData *sendData=[NSJSONSerialization dataWithJSONObject:msgDic
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:nil];
    NSLog(@"send Group message connectedPeer is %d",self.connectingPeers.count);
    BOOL result=[self.nearbySession sendData:sendData toPeers:self.nearbySession.connectedPeers withMode:MCSessionSendDataReliable error:nil];
    if (!result) {
        NSLog(@"PeerSendGroupMessageFailed: %@ ", content);
    }
}

-(void)sendReview:(NSString *)tag
           toPeer:(NSString *)uuid
{
    NSArray *connectedPeers=self.nearbySession.connectedPeers;
    for (MCPeerID *peer in connectedPeers) {
        if ([peer.displayName isEqualToString:uuid]) {
            NSLog(@"sendReview : %@ to Peer:%@",tag,uuid);
            NSDictionary *msgDic=@{@"review": @{@"tag": tag}};
            NSData *sendData=[NSJSONSerialization dataWithJSONObject:msgDic
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:nil];
            [self.nearbySession sendData:sendData toPeers:@[peer] withMode:MCSessionSendDataReliable error:nil];
        }
    }
}
*/
#pragma mark MCNearby Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSString *tips=[NSString stringWithFormat:@"发现iOS7节点:%@", peerID.displayName];
    NSLog(@"%@",tips);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RADER_TOOTH object:nil];
/*
//    for (MCPeerID *peer in self.connectingPeers) {
//        if ([peer.displayName isEqualToString:peerID.displayName]) {
//            NSLog(@"正在连接中,发现了同样的节点:%@",peerID.displayName);
//            return;
//        }
//    }

    BOOL shouldInvite = ([_myPeerID.displayName compare:peerID.displayName]==NSOrderedDescending);
    if (shouldInvite)
    {
//        [self.connectingPeers addObject:peerID];
        [browser invitePeer:peerID toSession:_nearbySession withContext:nil timeout:5.0];
    }
    else
        NSLog(@"Not inviting");
 */
    [browser invitePeer:peerID toSession:_nearbySession withContext:nil timeout:5.0];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSString *tips=[NSString stringWithFormat:@"失去iOS7节点:%@", peerID.displayName];
    NSLog(@"%@",tips);
//    [_connectingPeers removeObject:peerID];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSString *tips=@"搜索无法启动!";
    NSLog(@"%@",tips);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{

    invitationHandler(YES,_nearbySession);

    NSLog(@"确认交换中...");

}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"广播服务启动不成功!");
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"didChangeState");

    
    if (state==MCSessionStateConnected) {
//        [_connectingPeers removeObject:peerID];
        NSString *tips=[NSString stringWithFormat:@"连接成功,目前iOS7成功连接的节点数:%d", _nearbySession.connectedPeers.count];
        NSLog(@"%@",tips);
    }
    else if (state==MCSessionStateNotConnected)
    {
//        [_connectingPeers removeObject:peerID];
        NSString *tips=[NSString stringWithFormat:@"失去连接,目前iOS7成功连接的节点数:%d",_nearbySession.connectedPeers.count];
        NSLog(@"%@",tips);
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"节点收到数据");
}


@end
