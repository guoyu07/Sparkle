//
//  SUProbingUpdateDriver.m
//  Sparkle
//
//  Created by Mayur Pawashe on 3/18/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

#import "SUProbingUpdateDriver.h"
#import "SUBasicUpdateDriver.h"

#ifdef _APPKITDEFINES_H
#error This is a "core" class and should NOT import AppKit
#endif

@interface SUProbingUpdateDriver () <SUBasicUpdateDriverDelegate>

@property (nonatomic, readonly) SUBasicUpdateDriver *basicDriver;
@property (nonatomic) SUDownloadedUpdate *downloadedUpdate;

@end

@implementation SUProbingUpdateDriver

@synthesize basicDriver = _basicDriver;
@synthesize downloadedUpdate = _downloadedUpdate;

- (instancetype)initWithHost:(SUHost *)host updater:(id)updater updaterDelegate:(id <SPUUpdaterDelegate>)updaterDelegate
{
    self = [super init];
    if (self != nil) {
        _basicDriver = [[SUBasicUpdateDriver alloc] initWithHost:host updater:updater updaterDelegate:updaterDelegate delegate:self];
    }
    return self;
}

- (void)checkForUpdatesAtAppcastURL:(NSURL *)appcastURL withUserAgent:(NSString *)userAgent httpHeaders:(NSDictionary * _Nullable)httpHeaders completion:(SUUpdateDriverCompletion)completionBlock
{
    // We don't preflight for update permission in this driver because we are just interested if an update is available
    
    [self.basicDriver prepareCheckForUpdatesWithCompletion:completionBlock];
    
    [self.basicDriver checkForUpdatesAtAppcastURL:appcastURL withUserAgent:userAgent httpHeaders:httpHeaders includesSkippedUpdates:NO];
}

- (void)resumeInstallingUpdateWithCompletion:(SUUpdateDriverCompletion)completionBlock
{
    [self.basicDriver resumeInstallingUpdateWithCompletion:completionBlock];
}

- (void)resumeDownloadedUpdate:(SUDownloadedUpdate *)downloadedUpdate completion:(SUUpdateDriverCompletion)completionBlock
{
    self.downloadedUpdate = downloadedUpdate;
    
    [self.basicDriver resumeDownloadedUpdate:downloadedUpdate completion:completionBlock];
}

- (void)basicDriverDidFindUpdateWithAppcastItem:(SUAppcastItem *)__unused appcastItem
{
    // Stop as soon as we have an answer
    [self abortUpdate];
}

- (void)basicDriverIsRequestingAbortUpdateWithError:(nullable NSError *)error
{
    [self abortUpdateWithError:error];
}

- (void)abortUpdate
{
    [self abortUpdateWithError:nil];
}

- (void)abortUpdateWithError:(nullable NSError *)error
{
    [self.basicDriver abortUpdateAndShowNextUpdateImmediately:NO downloadedUpdate:self.downloadedUpdate error:error];
}

@end
