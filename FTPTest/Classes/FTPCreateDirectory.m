//
//  FTPCreateDirectory.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTPCreateDirectory.h"

@implementation FTPCreateDirectory

- (void)startCreating
{
    if ( !self.url || !self.filePath ) {
        return;
    }
    NSString *fileName = [self.filePath lastPathComponent];
    NSURL *anUrl = [self.url URLByAppendingPathComponent:fileName isDirectory:YES];
    NSLog(@"%@",[anUrl absoluteURL]);
    
    CFWriteStreamRef ftpStream;
    ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef)anUrl);
    if ( !ftpStream ) {
        NSLog(@"ERROR:%@",[anUrl absoluteURL]);
        return;
    }
    self.outputStream = (__bridge NSOutputStream*)ftpStream;
    self.outputStream.delegate = self;
    
    CFRelease(ftpStream);
    
    if ( self.username ) {
        [self.outputStream setProperty:self.username forKey:(NSString*)kCFStreamPropertyFTPUserName];
    }
    if ( self.password ) {
        [self.outputStream setProperty:self.password forKey:(NSString*)kCFStreamPropertyFTPPassword];
    }
    
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
    
    self.isRunning = YES;
    [self changeStatus:kFTPStatusStarting];
}

- (void)_stopSending
{
    self.isRunning = NO;
    if ( self.outputStream ) {
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream.delegate = nil;
        self.outputStream = nil;
    }
    if ( self.inputStream ) {
        [self.inputStream close];
        self.inputStream = nil;
    }
}

- (void)stopSending
{
    [self _stopSending];
    [self changeStatus:kFTPStatusClosed];
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            [self changeStatus:kFTPStatusOpened];
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable:// should not happen
            NSLog(@"NSStreamEventHasBytesAvailable");
            break;
        case NSStreamEventHasSpaceAvailable:
            [self changeStatus:kFTPStatusSending];
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:
            [self changeStatus:kFTPStatusError];
            NSLog(@"NSStreamEventErrorOccurred");
            NSLog(@"%@",[aStream streamError]);
            [self _stopSending];
            break;
        case NSStreamEventEndEncountered:// ignore
            [self changeStatus:kFTPStatusEnding];
            NSLog(@"NSStreamEventEndEncountered");
            [self stopSending];
            break;
    }
}

- (void)startRunning
{
    [self startCreating];
}

- (void)stopRunning
{
    [self stopSending];
}

@end
