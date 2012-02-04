//
//  FTPOperation.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTPOperation.h"
#import "FTPGetter.h"
#import "FTPPutter.h"
#import "FTPCreateDirectory.h"


@interface FTPOperation () <FTPRequestDelegate>

@property(atomic,retain) FTPRequest *ftpRequest;
@property(atomic,assign) NSInteger dirIndex;
@property(atomic,copy) NSURL *currentURL;

@end

@implementation FTPOperation

@synthesize baseURL, username, password, idirs;
@synthesize filePath;
@synthesize ftpRequest;
@synthesize status = _status;
@synthesize dirIndex = _dirIndex;
@synthesize currentURL;
@synthesize delegate;

- (NSString*)fileName
{
    return [self.filePath lastPathComponent];
}

-(void)ftpOperationDidChanged
{
    if ( [self.delegate respondsToSelector:@selector(ftpOperationDidChangeStatus:)] ) {
        [self.delegate ftpOperationDidChangeStatus:self.status];
    }
}

- (void)putFile
{
    self.status = kFTPOperationPutFile;
    self.ftpRequest = [[FTPPutter alloc] init];
    self.ftpRequest.username = self.username;
    self.ftpRequest.password = self.password;
    self.ftpRequest.url = self.currentURL;
    self.ftpRequest.filePath = self.filePath;
    self.ftpRequest.delegate = self;
    [self.ftpRequest startRunning];
}

- (void)didEndPutFile
{
    NSInteger status = self.ftpRequest.status;
    self.ftpRequest.delegate = nil;
//    [self.ftpRequest stopRunning];
    self.ftpRequest = nil;
    if ( status == kFTPStatusClosed ) {
        self.status = kFTPOperationDidEnd;
    } else {
        self.status = kFTPOperationErrorPut;
    }
    [self ftpOperationDidChanged];
}

- (void)createDirectory
{
    self.status = kFTPOperationCreateDirs;
    NSString *aString = [self.idirs objectAtIndex:self.dirIndex];
    self.ftpRequest = [[FTPCreateDirectory alloc] init];
    self.ftpRequest.username = self.username;
    self.ftpRequest.password = self.password;
    self.ftpRequest.url = self.currentURL;
    self.ftpRequest.filePath = aString;
    self.ftpRequest.delegate = self;
    [self.ftpRequest startRunning];
}

- (void)didEndCreateDirectory
{
    NSInteger status = self.ftpRequest.status;
    self.ftpRequest.delegate = nil;
//    [self.ftpRequest stopRunning];
    self.ftpRequest = nil;
    if ( status == kFTPStatusClosed ) {
        NSString *aString = [self.idirs objectAtIndex:self.dirIndex++];
        NSURL *anURL= [self.currentURL URLByAppendingPathComponent:aString isDirectory:YES];
        self.currentURL = anURL;
        if ( self.dirIndex >= self.idirs.count ) {
            [self putFile];
        } else {
            [self createDirectory];
        }
    } else {
        self.status = kFTPOperationErrorDirs;
        [self ftpOperationDidChanged];
    }
}

- (void)hasDirectory
{
    self.status = kFTPOperationCheckDirs;
    NSString *aString = [self.idirs objectAtIndex:self.dirIndex];
    NSURL *anURL = [self.currentURL URLByAppendingPathComponent:aString isDirectory:YES];
    NSString *aPath = [anURL absoluteString];
    NSLog(@"%s %@,%@,%@",__func__,aString,self.username,self.password);
    NSLog(@"%@",aPath);
    FTPGetter *ftpGetter = [[FTPGetter alloc] init];
    ftpGetter.username = self.username;
    ftpGetter.password = self.password;
    ftpGetter.url = anURL;
    ftpGetter.delegate = self;
    [ftpGetter startRunning];
    self.ftpRequest = ftpGetter;
}

- (void)didSuccessHasDirectory
{
    NSString *aString = [self.idirs objectAtIndex:self.dirIndex++];
    NSURL *anURL = [self.currentURL URLByAppendingPathComponent:aString isDirectory:YES];
    self.currentURL = anURL;
    if ( (self.dirIndex) >= self.idirs.count ) {
        [self putFile];
    } else {
        [self hasDirectory];
    }
}

- (void)didFailHasDirectory
{
    [self createDirectory];
}

- (void)didEndHasDirectory
{
    NSInteger status = self.ftpRequest.status;
    self.ftpRequest.delegate = nil;
//    [self.ftpRequest stopRunning];
    self.ftpRequest = nil;
    if ( status == kFTPStatusClosed ) {
        [self didSuccessHasDirectory];
    } else {
        [self didFailHasDirectory];
    }
}

- (void)run
{
    self.dirIndex = 0;
    self.currentURL = [NSURL URLWithString:self.baseURL];
    if ( self.dirIndex >= self.idirs.count ) {
        [self putFile];
        return;
    }
    [self hasDirectory];
}

-(void)ftpStatusDidChanged:(enum FTPstatus_enum)status
{
    NSLog(@"%s operation = %d, request = %d",__func__,self.status,status);
    switch (self.status) {
        case kFTPOperationCheckDirs:{
            if ( status == kFTPStatusClosed ||
                status == kFTPStatusError ) {
                [self didEndHasDirectory];
            }
        } break;

        case kFTPOperationCreateDirs:{
            if ( status == kFTPStatusClosed ||
                status == kFTPStatusError ) {
                [self didEndCreateDirectory];
            }
        } break;

        case kFTPOperationPutFile:{
            if ( status == kFTPStatusClosed ||
                status == kFTPStatusError ) {
                [self didEndPutFile];
            }
        } break;

        case kFTPOperationNotRunnging:
        case kFTPOperationErrorPut:
        case kFTPOperationErrorDirs:
        default:
            self.ftpRequest.delegate = nil;
//            [self.ftpRequest stopRunning];
            self.ftpRequest = nil;
            break;
    }   
}

- (NSInteger)dirsFromString:(NSString*)aString
{
    self.idirs = [aString componentsSeparatedByString:@"/"];
    return self.idirs.count;
}

@end
