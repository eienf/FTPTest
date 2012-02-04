//
//  FTPRequest.h
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum FTPstatus_enum {
    kFTPStatusNotRunning = 0,
    kFTPStatusStarting = 1,
    kFTPStatusOpened = 2,
    kFTPStatusReceiving = 3,
    kFTPStatusSending = 4,
    kFTPStatusEnding = 8,
    kFTPStatusError = 9,
    kFTPStatusClosed = 10,
};

@protocol FTPRequestDelegate <NSObject>

- (void)ftpStatusDidChanged:(enum FTPstatus_enum)status;

@end

@interface FTPRequest : NSObject <NSStreamDelegate>

@property(nonatomic,copy) NSString *username;
@property(nonatomic,copy) NSString *password;
@property(nonatomic,copy) NSURL *url;
@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,strong) NSInputStream *inputStream;
@property(nonatomic,strong) NSOutputStream *outputStream;
@property(nonatomic,assign) BOOL isRunning;
@property(atomic,assign) NSInteger status;
@property(nonatomic,weak) id<FTPRequestDelegate> delegate;

- (void)changeStatus:(NSInteger)status;
- (void)statusDidChanged;
- (void)startRunning;
- (void)stopRunning;

@end
