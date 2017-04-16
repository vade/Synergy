//
//  ViewController.m
//  Synergy-macOS
//
//  Created by vade on 4/16/17.
//  Copyright © 2017 Synopsis. All rights reserved.
//

#import "Shared.h"

#import "NetworkViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface NetworkViewController () <NSNetServiceDelegate>

@property (readwrite, strong) GCDAsyncSocket* asyncSocket;
@property (readwrite, strong) NSMutableArray* connectedSockets;
@property (readwrite, strong) NSNetServiceBrowser* netServiceBrowser;


@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.includesPeerToPeer = YES;
    self.netServiceBrowser.delegate = self;
    
    [self.netServiceBrowser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.netServiceBrowser searchForServicesOfType:kSynergyNetServiceType inDomain:@"local."];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


#pragma mark - NetServiceBrowser Delegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"netServiceBrowserWillSearch");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"NetService Browswr found service: %@", service);
}


@end
