//
//  NetworkServiceCollectionViewItem.h
//  Synergy
//
//  Created by vade on 4/16/17.
//  Copyright © 2017 Synopsis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NetworkServiceCollectionViewItem : NSCollectionViewItem
@property (readwrite, strong) IBOutlet NSTextField* hostName;
@property (readwrite, strong) IBOutlet NSTextField* address;
@property (readwrite, strong) IBOutlet NSTextField* port;

@end
