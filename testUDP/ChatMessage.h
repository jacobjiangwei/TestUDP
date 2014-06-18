//
//  ChatMessage.h
//  testUDP
//
//  Created by Jiang Jacob on 6/18/14.
//  Copyright (c) 2014 ToolWiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property (nonatomic,strong)    NSString *content;
@property (nonatomic,strong)    NSString *type;
@property (nonatomic,assign)    BOOL     isSend;

@end
