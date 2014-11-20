//
//  AppDelegate.h
//  Junction
//
//  Created by John Hobbs on 11/19/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SocketIO.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SocketIODelegate, NSUserNotificationCenterDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) SocketIO *socketIO;

@end

