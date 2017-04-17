//
//  ViewController.m
//  Synergy-macOS
//
//  Created by vade on 4/16/17.
//  Copyright © 2017 Synopsis. All rights reserved.
//

#import "Shared.h"

#import "NetworkViewController.h"
#import "NetworkServiceCollectionViewItem.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface NetworkViewController () <NSNetServiceBrowserDelegate, NSNetServiceDelegate, NSCollectionViewDelegate, NSCollectionViewDataSource, GCDAsyncSocketDelegate>

@property (readwrite, strong) NSNetServiceBrowser* netServiceBrowser;
@property (readwrite, strong) NSMutableArray<NSNetService*>* discoveredServices;
@property (readwrite, strong) NSMutableArray<GCDAsyncSocket*>* sockets;

@property (readwrite, strong) dispatch_queue_t delegateQueue;


@property (readwrite, strong) IBOutlet NSCollectionView* collectionView;

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.discoveredServices = [NSMutableArray array];
    self.sockets = [NSMutableArray array];
    
    self.delegateQueue = dispatch_queue_create("delegateQueue", DISPATCH_QUEUE_SERIAL);
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.includesPeerToPeer = YES;
    self.netServiceBrowser.delegate = self;
    
    [self.netServiceBrowser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.netServiceBrowser searchForServicesOfType:kSynergyNetServiceType inDomain:@"local."];
    
    NSNib* nib = [[NSNib alloc] initWithNibNamed:@"NetworkServiceCollectionViewItem" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forItemWithIdentifier:@"NetworkServiceCollectionViewItem"];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)viewWillLayout
{
    NSLog(@"layout");
    ((NSCollectionViewFlowLayout*)(self.collectionView.collectionViewLayout)).itemSize = NSMakeSize(self.collectionView.bounds.size.width, 56);
}

#pragma mark - NetServiceBrowser Delegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"netServiceBrowserWillSearch");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"NetService Browser found service: %@", service);
    
    service.delegate = self;
    [service resolveWithTimeout:2.0];
    [service startMonitoring];
    
    [self.discoveredServices addObject:service];
    
    [self.collectionView reloadData];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"NetService Browser removed service: %@", service);

    [self.discoveredServices removeObject:service];

    [self.collectionView reloadData];
}

#pragma mark - Netservice Delegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"Resolved, update UI");
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
    NSLog(@"Update TXT Record / UI");
    
    NSDictionary* txtDict = [NSNetService dictionaryFromTXTRecordData:data];
//
    //    NSNumber* version = txtDict[kSynergyNetServiceVersion];
    NSString* deviceName = [[NSString alloc] initWithData:txtDict[kSynergyDeviceName] encoding:NSUTF8StringEncoding];
    NSString* deviceModel = [[NSString alloc] initWithData:txtDict[kSynergyDeviceModel] encoding:NSUTF8StringEncoding];
    NSString* deviceOS = [[NSString alloc] initWithData:txtDict[kSynergyDeviceSystemVersion] encoding:NSUTF8StringEncoding];
    NSString* deviceUUID = [[NSString alloc] initWithData:txtDict[kSynergyDeviceVendorUUID] encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@, %@ %@, %@", deviceName, deviceModel, deviceOS, deviceUUID);
}

#pragma mark - NSCollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.discoveredServices.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NetworkServiceCollectionViewItem* item = (NetworkServiceCollectionViewItem*)[self.collectionView makeItemWithIdentifier:@"NetworkServiceCollectionViewItem" forIndexPath:indexPath];
    
    NSNetService* service = [self.discoveredServices objectAtIndex:indexPath.item];
    
    if(service.hostName)
    {
        item.hostName.stringValue = service.hostName;
    }
    
    NSDictionary* txtDict = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
    
    NSString* versionMajor = [[NSString alloc] initWithData:txtDict[kSynergyNetServiceVersionMajor] encoding:NSUTF8StringEncoding];
    NSString* versionMinor = [[NSString alloc] initWithData:txtDict[kSynergyNetServiceVersionMinor] encoding:NSUTF8StringEncoding];
    NSString* deviceName = [[NSString alloc] initWithData:txtDict[kSynergyDeviceName] encoding:NSUTF8StringEncoding];
    NSString* deviceModel = [[NSString alloc] initWithData:txtDict[kSynergyDeviceModel] encoding:NSUTF8StringEncoding];
    NSString* deviceOS = [[NSString alloc] initWithData:txtDict[kSynergyDeviceSystemVersion] encoding:NSUTF8StringEncoding];
    NSString* deviceUUID = [[NSString alloc] initWithData:txtDict[kSynergyDeviceVendorUUID] encoding:NSUTF8StringEncoding];

    NSLog(@"%@, %@ %@, %@", deviceName, deviceModel, deviceOS, deviceUUID);
    
    item.port.stringValue = [NSString stringWithFormat:@"%li", service.port];
    
    return item;
}

#pragma mark - NSCollectionView Delegate Methods


#pragma mark - GCDASyncSocket Delegate Methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"Connect");
    NSString* connectSYN = @"kSynergyProtocolTagConnectSyn";
    NSData* connectSYNData = [connectSYN dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:connectSYNData withTimeout:2 tag:kSynergyProtocolTagConnectSyn];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    switch (tag) {
        case kSynergyProtocolTagConnectSyn:
            [sock readDataWithTimeout:2 tag:kSynergyProtocolTagConnectAck];

            break;
            
        default:
            break;
    }

}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(nonnull NSData *)data withTag:(long)tag
{
    NSLog(@"readData");
    switch(tag)
    {
        case kSynergyProtocolTagConnectAck:
        {
            NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([string isEqualToString:@"kSynergyProtocolTagConnectAck"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NetworkServiceCollectionViewItem* item = [self itemForSocket:sock];
                    [item setStatus:2];
                });
            }
        }
    }
}

#pragma mark - Actions

- (NSIndexPath*) indexPathForSocket:(GCDAsyncSocket*)sock
{
    NSUInteger index = [self.sockets indexOfObject:sock];
    
    return [NSIndexPath indexPathForItem:index inSection:0];
}

-(NetworkServiceCollectionViewItem*) itemForSocket:(GCDAsyncSocket*)sock
{
    NSIndexPath* indexPath = [self indexPathForSocket:sock];
    
    return (NetworkServiceCollectionViewItem*)[self.collectionView itemAtIndexPath:indexPath];
}


- (IBAction)synchronize:(id)sender
{
    
    for(GCDAsyncSocket* sock in self.sockets)
    {
        [sock disconnect];
    }

    [self.sockets removeAllObjects];
    
    
    for(NSNetService* service in self.discoveredServices)
    {
        dispatch_queue_t socketQueue = dispatch_queue_create("socketqueue", DISPATCH_QUEUE_SERIAL);
        GCDAsyncSocket* socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue socketQueue:socketQueue];
        
        // Associate our socket with our NSNetService
        socket.userData = service;
        
        NSError* error = nil;
        [socket connectToHost:service.hostName onPort:service.port error:&error];
        
        [self.sockets addObject:socket];
    }
}

@end
