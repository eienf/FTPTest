//
//  OperationViewController.h
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTPOperation.h"

@interface OperationViewController : UIViewController
    <UITextFieldDelegate,FTPOperationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlView;
@property (weak, nonatomic) IBOutlet UITextField *usernameView;
@property (weak, nonatomic) IBOutlet UITextField *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *dirsView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
