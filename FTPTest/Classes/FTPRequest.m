//
//  FTPRequest.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTPRequest.h"

@implementation FTPRequest

@synthesize username = _username;
@synthesize password = _password;
@synthesize url = _url;
@synthesize filePath = _filePath;
@synthesize isRunning = _isRunning;
@synthesize status = _status;
@synthesize inputStream;
@synthesize outputStream;
@synthesize delegate;

- (void)statusDidChanged
{
    if ( [self.delegate respondsToSelector:@selector(ftpStatusDidChanged:)] ) {
        [self.delegate ftpStatusDidChanged:self.status];
    }
}

- (void)changeStatus:(NSInteger)status
{
    self.status = status;
    if ( status == kFTPStatusNotRunning ||
        status == kFTPStatusClosed ||
        status == kFTPStatusError ) {
        self.isRunning = NO;
    }
    [self statusDidChanged];
}

- (void)startRunning
{
    
}

- (void)stopRunning
{
    
}

@end
