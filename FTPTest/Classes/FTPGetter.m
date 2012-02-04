//
//  FTPGetter.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTPGetter.h"

@implementation FTPGetter

- (void)startReceiving
{
    NSString *filePath = [self.url lastPathComponent];
    if ( [filePath length] == 0 ) {
        NSLog(@"ERROR:%@",self.url);
    }
    filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
    self.filePath = filePath;
    NSLog(@"new file : %@",filePath);
    
    NSOutputStream *fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    if ( !fileStream ) {
        NSLog(@"ERROR:%@",filePath);
    }
    [fileStream open];
    self.outputStream = fileStream;

    CFReadStreamRef ftpStream;
    ftpStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef)self.url);
    if ( ftpStream == NULL ) {
        NSLog(@"ERROR:%@",[self.url absoluteURL]);
        return;
    }
    self.inputStream = (__bridge NSInputStream*)ftpStream;
    self.inputStream.delegate = self;
    
    CFRelease(ftpStream);
    
    if ( self.username ) {
        [self.inputStream setProperty:self.username forKey:(NSString*)kCFStreamPropertyFTPUserName];
    }
    if ( self.password ) {
        [self.inputStream setProperty:self.password forKey:(NSString*)kCFStreamPropertyFTPPassword];
    }

    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];

    self.isRunning = YES;
    [self changeStatus:kFTPStatusStarting];
}

- (void)_stopReceiving
{
    self.isRunning = NO;
    if ( self.inputStream ) {
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream close];
        self.inputStream.delegate = nil;
        self.inputStream = nil;
    }
    if ( self.outputStream ) {
        [self.outputStream close];
        self.outputStream = nil;
    }
}

- (void)stopReceiving
{
    [self _stopReceiving];
    [self changeStatus:kFTPStatusClosed];
}

- (void)receivingFromStream:(NSInputStream*)aStream
{
    NSInteger       bytesRead;
    uint8_t         buffer[32768];
    
    bytesRead = [aStream read:buffer maxLength:sizeof(buffer)];
    if (bytesRead == -1) {
        NSLog(@"Error while reading");
        self.status = kFTPStatusError;
    } else if (bytesRead == 0) {
        NSLog(@"Download did End.");
        [self stopReceiving];
    } else {
        NSInteger   bytesWritten;
        NSInteger   bytesWrittenSoFar;
        
        // Write to the file.
        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [self.outputStream write:&buffer[bytesWrittenSoFar] maxLength:bytesRead - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                [self changeStatus:kFTPStatusError];
                break;
            } else {
                bytesWrittenSoFar += bytesWritten;
            }
        } while (bytesWrittenSoFar != bytesRead);
        buffer[bytesRead] = 0;
        NSLog(@"(%s)",buffer);
    }
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            [self changeStatus:kFTPStatusOpened];
            NSLog(@"NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable:
            [self changeStatus:kFTPStatusReceiving];
            NSLog(@"NSStreamEventHasBytesAvailable");
            [self receivingFromStream:(NSInputStream*)aStream];
            break;
        case NSStreamEventHasSpaceAvailable:// should not happen
            NSLog(@"NSStreamEventHasSpaceAvailable");
            break;
        case NSStreamEventErrorOccurred:
            [self changeStatus:kFTPStatusError];
            NSLog(@"NSStreamEventErrorOccurred");
            NSLog(@"%@",[aStream streamError]);
            [self _stopReceiving];
            break;
        case NSStreamEventEndEncountered:// ignore
            [self changeStatus:kFTPStatusEnding];
            NSLog(@"NSStreamEventEndEncountered");
            break;
    }
}

- (void)startRunning
{
    [self startReceiving];
}

- (void)stopRunning
{
    [self stopReceiving];
}

@end
