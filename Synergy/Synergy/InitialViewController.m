//
//  ViewController.m
//  Synergy
//
//  Created by vade on 4/16/17.
//  Copyright © 2017 Synopsis. All rights reserved.
//
#import "Shared.h"

#import "InitialViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#include <sys/types.h>
#include <sys/sysctl.h>

@interface InitialViewController () <GCDAsyncSocketDelegate, NSNetServiceDelegate>

@property (readwrite, strong) GCDAsyncSocket* asyncSocket;
@property (readwrite, strong) NSMutableArray* connectedSockets;
@property (readwrite, strong) NSNetService* netService;

@end

@implementation InitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.connectedSockets = [[NSMutableArray alloc] init];

    self.view.layer.backgroundColor = [UIColor redColor].CGColor;

    NSError *err = nil;
    if ([self.asyncSocket acceptOnPort:0 error:&err])
    {
        

        UInt16 port = [self.asyncSocket localPort];

        self.netService = [[NSNetService alloc] initWithDomain:@"local."
                                                          type:kSynergyNetServiceType
                                                          name:kSynergyNetServiceName
                                                          port:port];
        [self.netService setDelegate:self];
        [self.netService publish];

        NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:4];
//        [txtDict setObject:@"moo" forKey:@"cow"];
//        [txtDict setObject:@"quack" forKey:@"duck"];
//        [txtDict setObject:kSynergyNetServiceVersion forKey:@(1)];

        [txtDict setObject:@"0" forKey:kSynergyNetServiceVersionMajor];
        [txtDict setObject:@"0" forKey:kSynergyNetServiceVersionMinor];

        [txtDict setObject:[UIDevice currentDevice].name forKey:kSynergyDeviceName];
        [txtDict setObject:[self hardwareDescription] forKey:kSynergyDeviceModel];
        [txtDict setObject:[UIDevice currentDevice].systemVersion forKey:kSynergyDeviceSystemVersion];
        [txtDict setObject:[[UIDevice currentDevice].identifierForVendor UUIDString] forKey:kSynergyDeviceVendorUUID];
        
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
        if(![self.netService setTXTRecordData:txtData])
        {
            NSLog(@"Failed to set txtRecordData");
        }
    }
    else
    {
        NSLog(@"Error in acceptOnPort:error: -> %@", err );
    }

}

#pragma mark - GCDAsyncSocket Delegate Methods

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    // The newSocket automatically inherits its delegate & delegateQueue from its parent.
    
    [self.connectedSockets addObject:newSocket];
    
    self.view.layer.backgroundColor = [UIColor greenColor].CGColor;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"Disconnected new socket from %@:%hu", [sock connectedHost], [sock connectedPort]);

    [self.connectedSockets removeObject:sock];
}

#pragma mark - NSNetservice Delegate Methods

- (void)netServiceDidPublish:(NSNetService *)ns
{
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
              [ns domain], [ns type], [ns name], (int)[ns port]);

    self.view.layer.backgroundColor = [UIColor yellowColor].CGColor;

}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
    // Override me to do something here...
    //
    // Note: This method in invoked on our bonjour thread.
    
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
               [ns domain], [ns type], [ns name], errorDict);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (NSString*)hardwareDescription {
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"i386"]) return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"]) return @"Simulator";
    
    return hardware;
}

- (NSString*)hardwareString {
    size_t size = 100;
    char *hw_machine = malloc(size);
    int name[] = {CTL_HW,HW_MACHINE};
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

@end
