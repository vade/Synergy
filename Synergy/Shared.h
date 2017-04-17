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
//static NSString* kSynergyNetServiceName = @"_synergy_";

static NSString* kSynergyNetServiceVersionMajor = @"VersionMajor";
static NSString* kSynergyNetServiceVersionMinor = @"VersionMinor";

static NSString* kSynergyDeviceName = @"Name";
static NSString* kSynergyDeviceModel = @"Model";
static NSString* kSynergyDeviceSystemVersion = @"SystemVersion";
static NSString* kSynergyDeviceVendorUUID = @"VendorUUID";


const NSUInteger kSynergyProtocolTagConnectSyn = 0;
const NSUInteger kSynergyProtocolTagConnectAck = 1;

const NSUInteger kSynergyProtocolTagSyncronizeSyn = 10;
const NSUInteger kSynergyProtocolTagSyncronizeAck = 11;


#endif /* Shared_h */
