//
//  GTExceptionalDeviceInfo.h
//  GetexceptionalAPI
//
//  Created by Jörg Polakowski on 23/05/11.
//  Copyright 2011 mobile melting GmbH. All rights reserved.
//
//  Used to determine EXACT version of device software is running on.
//  Taken from: http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk/1561920#1561920
//

#import <Foundation/Foundation.h>

@interface GTExceptionalDeviceInfo : NSObject 

+ (NSString *) platform;
+ (NSString *) platformString;

@end
