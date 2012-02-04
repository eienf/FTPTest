//
//  FTPPutter.h
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FTPRequest.h"

@interface FTPPutter : FTPRequest {
    uint8_t _buffer[32768];
}

- (void)startSending;

@end
