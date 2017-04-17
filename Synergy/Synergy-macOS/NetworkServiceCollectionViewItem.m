//
//  NetworkServiceCollectionViewItem.m
//  Synergy
//
//  Created by vade on 4/16/17.
//  Copyright © 2017 Synopsis. All rights reserved.
//

#import "NetworkServiceCollectionViewItem.h"

@interface NetworkServiceCollectionViewItem ()
@property (readwrite, strong) IBOutlet NSImageView* statusImageView;
@end

@implementation NetworkServiceCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setStatus:0];
    // Do view setup here.
}


- (void) setStatus:(NSUInteger)status
{
    switch (status) {
        case 0:
            self.statusImageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
            break;
        case 1:
            self.statusImageView.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
            break;
        case 2:
            self.statusImageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
            break;
            
        default:
            break;
    }
}


@end
