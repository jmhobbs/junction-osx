//
//  JunctionPacket.h
//  Junction
//
//  Created by John Hobbs on 12/16/14.
//  Copyright (c) 2014 John Hobbs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JunctionPacket : NSObject

- (id)initWithData:(NSData *)data andVerify:(NSString *)key;

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSNumber *timestamp;


@end
