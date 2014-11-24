//
//  AppDelegate.m
//  Junction
//
//  Created by John Hobbs on 11/19/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "AppDelegate.h"

#define kPrefsAPIKey        @"apiKey"
#define kPrefsServerDomain  @"serverDomain"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *serverDomain;

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@property (weak) IBOutlet NSTextField *apiKeyField;
@property (weak) IBOutlet NSTextField *serverDomainField;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSProgressIndicator *spinner;

- (IBAction)saveConfig:(id)sender;

@end

// [NSApp activateIgnoringOtherApps:YES];
// [_window makeKeyAndOrderFront:nil];

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // http://kmikael.com/2013/07/01/simple-menu-bar-apps-for-os-x/
    // https://github.com/nfarina/feeds/blob/master/Feeds/AppDelegate.m
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:16];
    _statusItem.title = @"";
    
    // The image that will be shown in the menu bar, a 16x16 black png works best
    _statusItem.image = [NSImage imageNamed:@"junction_offline16x16"];
    //    _statusItem.alternateImage = [NSImage imageNamed:@"feedbin-logo-alt"];
    _statusItem.highlightMode = NO;
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu addItemWithTitle:@"Configure" action:@selector(openConfig:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
    
    if( ! _delegateQueue ) {
        _delegateQueue = dispatch_queue_create("org.velvetcache.Junction.SocketDelegate", NULL);
    }
    
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_delegateQueue];
    _socket.delegate = self;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _apiKey = [prefs stringForKey:kPrefsAPIKey];
    _serverDomain = [prefs stringForKey:kPrefsServerDomain];
    
    if( _apiKey ) { [_apiKeyField setStringValue:_apiKey]; }
    if( _serverDomain ) { [_serverDomainField setStringValue:_serverDomain]; }
    
    if(_apiKey && _serverDomain) {
        NSLog(@"API Key and Server Domain Found!");
        [self connect];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [_socket disconnect];
}

- (void)openConfig:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:self];
}

- (void)terminate:(id)sender {
    [[NSApplication sharedApplication] terminate:self.statusItem.menu];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:notification.userInfo[@"link"]]];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

/*
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
 */


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
    NSError *error;
    NSLog(@"Connecting....");
    [_socket connectToHost:@"localhost" onPort:3000 error:&error];
    NSLog(@"Error: %@", error);
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost %@ : %d", host, port);
    [_socket writeData:[@"Hello" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:0];
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData");
}


/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag");
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
    NSLog(@"didWritePartialDataOfLength");
}

/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 *
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSLog(@"socket shouldTimeoutReadWithTag");
    return 0;
}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 *
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSLog(@"socket shouldTimeoutWriteWithTag");
    return 0;
}

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 *
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    NSLog(@"socketDidCloseReadStream");
}

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect: %@", err);
}


@end
