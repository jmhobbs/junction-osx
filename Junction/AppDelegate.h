//
//  AppDelegate.h
//  Junction
//
//  Created by John Hobbs on 11/19/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, GCDAsyncSocketDelegate>

@end

