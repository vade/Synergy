//
//  Shared.h
//  Synergy
//
//  Created by vade on 4/16/17.
//  Copyright © 2017 Synopsis. All rights reserved.
//

#ifndef Shared_h
#define Shared_h
#import <CoreFoundation/CoreFoundation.h>

static NSString* kSynergyNetServiceType = @"_synergy_vade_info._tcp.";
static NSString* kSynergyNetServiceName = @"_synergy_";

static NSString* kSynergyNetServiceVersionMajor = @"VersionMajor";
static NSString* kSynergyNetServiceVersionMinor = @"VersionMinor";

static NSString* kSynergyDeviceName = @"Name";
static NSString* kSynergyDeviceModel = @"Model";
static NSString* kSynergyDeviceSystemVersion = @"SystemVersion";
static NSString* kSynergyDeviceVendorUUID = @"VendorUUID";


NSUInteger kSynergyProtocolTagConnectSyn = 0;
NSUInteger kSynergyProtocolTagConnectAck = 1;

NSUInteger kSynergyProtocolTagSyncronizeSyn = 10;
NSUInteger kSynergyProtocolTagSyncronizeAck = 11;


#endif /* Shared_h */
