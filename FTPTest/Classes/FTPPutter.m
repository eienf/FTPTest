//
//  FTPPutter.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTPPutter.h"

#define kSendBufferSize (32768)

@interface FTPPutter ()

@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;
@property (nonatomic, readonly) uint8_t *         buffer;

@end

@implementation FTPPutter

@synthesize bufferOffset = _bufferOffset;
@synthesize bufferLimit = _bufferLimit;

-(uint8_t*)buffer{ return _buffer;}

- (void)startSending
{
    if ( [self.filePath length] == 0 ) {
        return;
    }

    NSInputStream *fileStream = [NSInputStream inputStreamWithFileAtPath:self.filePath];
    if ( !fileStream ) {
        NSLog(@"ERROR:%@",self.filePath);
        return;
    }
    [fileStream open];
    self.inputStream = fileStream;
    
    NSString *fileName = [self.filePath lastPathComponent];
    NSURL *anUrl = [self.url URLByAppendingPathComponent:fileName];
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

- (void)sendingToStream:(NSOutputStream*)aStream
{
    if (self.bufferOffset == self.bufferLimit) {
        NSInteger   bytesRead;
        
        bytesRead = [self.inputStream read:self.buffer maxLength:kSendBufferSize];
        
        if (bytesRead == -1) {
            [self changeStatus:kFTPStatusError];
            [self _stopSending];
        } else if (bytesRead == 0) {
            [self stopSending];
        } else {
            self.bufferOffset = 0;
            self.bufferLimit  = bytesRead;
        }
    }
    
    if (self.bufferOffset != self.bufferLimit) {
        NSInteger   bytesWritten;
        bytesWritten = [self.outputStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self changeStatus:kFTPStatusError];
            [self _stopSending];
        } else {
            self.bufferOffset += bytesWritten;
        }
    }
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
            [self sendingToStream:(NSOutputStream*)aStream];
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
            break;
    }
}

- (void)startRunning
{
    [self startSending];
}

- (void)stopRunning
{
    [self stopSending];
}

@end
