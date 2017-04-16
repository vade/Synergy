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

        
        NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [txtDict setObject:@"moo" forKey:@"cow"];
        [txtDict setObject:@"quack" forKey:@"duck"];
        
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
        [self.netService setTXTRecordData:txtData];

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


@end
