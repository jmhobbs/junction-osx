//
//  JunctionPacket.m
//  Junction
//
//  Created by John Hobbs on 12/16/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import "JunctionPacket.h"
#import <CommonCrypto/CommonHMAC.h>
#import "MessagePack.h"


NSData *sha256HMAC(NSString *key, NSData *data) {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData =  [data bytes]; //cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

@implementation JunctionPacket

/*
 {
 "id": 12345,
 "title": "derp",
 "body": "",              // Optional
 "url": "",               // Optional
 "image_url": "",         // Optional
 "timestamp": 123456789
 }
*/
- (id)initWithData:(NSData *)data andVerify:(NSString *)key {
    self = [super init];
 
    // Cut signature off the front end
    unsigned char cSignatureBuffer[CC_SHA256_DIGEST_LENGTH];
    [data getBytes:cSignatureBuffer length:CC_SHA256_DIGEST_LENGTH];
    NSData *packetSignature = [[NSData alloc] initWithBytes:cSignatureBuffer length:CC_SHA256_DIGEST_LENGTH];
    NSData *message = [data subdataWithRange:NSMakeRange(CC_SHA256_DIGEST_LENGTH, [data length] - CC_SHA256_DIGEST_LENGTH)];
    NSData *verificationSignature = sha256HMAC(key, message);
    
    // Is it really real?!?!
    if(! [verificationSignature isEqualToData:packetSignature]) { return nil; }

    NSDictionary* parsed = [message messagePackParse];
    if(! parsed) { return nil; }
    
    // TODO: Check for complete, valid object.
    self.id        = [parsed objectForKey:@"id"];
    self.title     = [parsed objectForKey:@"title"];
    self.body      = [parsed objectForKey:@"body"];
    self.url       = nil;
    self.imageURL  = nil;
    self.timestamp = [parsed objectForKey:@"timestamp"];
    
    if([parsed objectForKey:@"url"] && 0 < [[parsed objectForKey:@"url"] length]) {
        self.url = [NSURL URLWithString:[parsed objectForKey:@"url"]];
    }
    
    if([parsed objectForKey:@"image_url"] && 0 < [[parsed objectForKey:@"image_url"] length]) {
        self.imageURL = [NSURL URLWithString:[parsed objectForKey:@"image_url"]];
    }

    return self;
}

@end
