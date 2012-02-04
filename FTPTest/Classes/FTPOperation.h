//
//  FTPOperation.h
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    kFTPOperationNotRunnging = 0,
    kFTPOperationCheckDirs = 1,
    kFTPOperationCreateDirs = 2,
    kFTPOperationPutFile = 3,
    kFTPOperationDidEnd = 9,
    kFTPOperationErrorDirs = 10,
    kFTPOperationErrorPut = 11,
    kFTPOperationCacel = 20,
};

@protocol FTPOperationDelegate <NSObject>

- (void)ftpOperationDidChangeStatus:(NSInteger)status;

@end

@interface FTPOperation : NSObject

@property(nonatomic,copy) NSString *baseURL;
@property(nonatomic,copy) NSString *username;
@property(nonatomic,copy) NSString *password;
@property(nonatomic,copy) NSArray *idirs;
@property(nonatomic,copy) NSString *filePath;
@property(nonatomic,readonly) NSString *fileName;
@property(nonatomic,weak) id<FTPOperationDelegate> delegate;
@property(atomic,assign) NSInteger status;

- (void)run;
- (NSInteger)dirsFromString:(NSString*)aString;

@end
