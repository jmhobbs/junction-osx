//
//  AppDelegate.m
//  Junction
//
//  Created by John Hobbs on 11/19/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "AppDelegate.h"
#import "SocketIOPacket.h"

#define kPrefsAPIKey        @"apiKey"
#define kPrefsServerDomain  @"serverDomain"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *serverDomain;

@property (weak) IBOutlet NSTextField *apiKeyField;
@property (weak) IBOutlet NSTextField *serverDomainField;
@property (weak) IBOutlet NSButton *saveButton;

- (IBAction)saveConfig:(id)sender;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // http://kmikael.com/2013/07/01/simple-menu-bar-apps-for-os-x/
    // https://github.com/nfarina/feeds/blob/master/Feeds/AppDelegate.m
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:16];
    _statusItem.title = @"";
    
    // The image that will be shown in the menu bar, a 16x16 black png works best
    _statusItem.image = [NSImage imageNamed:@"junction16x16"];
    //    _statusItem.alternateImage = [NSImage imageNamed:@"feedbin-logo-alt"];
    _statusItem.highlightMode = NO;
    
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _apiKey = [prefs stringForKey:kPrefsAPIKey];
    _serverDomain = [prefs stringForKey:kPrefsServerDomain];
    
    if(_apiKey && _serverDomain) {
        NSLog(@"API Key and Server Domain Found!");
        [self connect];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [_socketIO disconnect];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:notification.userInfo[@"link"]]];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    NSLog(@"Checking present notification");
    return YES;
}

- (void) socketIODidConnect:(SocketIO *)socket {
    NSLog(@"Did Connect");
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    NSLog(@"Did Disconnect");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSLog(@"%@ - %@", packet.name, packet.args[0]);
    if([packet.name isEqualToString:@"message"]) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = packet.args[0][@"title"];
        notification.informativeText = packet.args[0][@"body"];
        notification.soundName = NSUserNotificationDefaultSoundName;
        notification.contentImage = [NSImage imageNamed:@"icon16x16"];
        notification.userInfo = @{@"link": packet.args[0][@"link"]};
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    NSLog(@"Error: %@", error);
}


- (IBAction)saveConfig:(id)sender {
    _apiKey = [_apiKeyField stringValue];
    _serverDomain = [_serverDomainField stringValue];
    
    // TODO: Test connection and key?
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_apiKey forKey:kPrefsAPIKey];
    [prefs setObject:_serverDomain forKey:kPrefsServerDomain];
    [prefs synchronize];
    
    [self connect];
}

- (void)connect {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [_window close];
    [_socketIO connectToHost:_serverDomain onPort:80];
}
@end
