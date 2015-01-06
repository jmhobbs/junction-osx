//
//  JunctionPacketTests.m
//  Junction
//
//  Created by John Hobbs on 12/16/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JunctionPacket.h"

@interface JunctionPacketTests : XCTestCase

@end

@implementation JunctionPacketTests


- (void)testExample {
    /*
     
    $data = array(
      'id'        => 1,
      'title'     => 'Hello World!',
      'body'      => 'Junction Junction!',
      'url'       => 'http://velvetcache.org/',
      'image_url' => '',
      'timestamp' => 1418764085
    );
     
    */

    NSString *base64 = @"ndsgya1D3O0u3ofwpwJm3vrH2uEIhTpuPj/uiNpX+pGGomlkAaV0aXRsZaxIZWxsbyBXb3JsZCGkYm9kebJKdW5jdGlvbiBKdW5jdGlvbiGjdXJst2h0dHA6Ly92ZWx2ZXRjYWNoZS5vcmcvqWltYWdlX3VybKCpdGltZXN0YW1wzlSQnzU=";
    NSData *packetData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    JunctionPacket *pkt = [[JunctionPacket alloc] initWithData:packetData andVerify:@"hi"];
    XCTAssertNotNil(pkt);
    XCTAssertEqualObjects(pkt.id, @1);
    XCTAssertEqualObjects(pkt.title, @"Hello World!");
    XCTAssertEqualObjects(pkt.body, @"Junction Junction!");
    XCTAssertEqualObjects(pkt.url, [NSURL URLWithString:@"http://velvetcache.org/"]);
    XCTAssertNil(pkt.imageURL);
    XCTAssertEqualObjects(pkt.timestamp, @1418764085);
}

@end
