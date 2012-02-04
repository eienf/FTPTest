//
//  OperationViewController.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OperationViewController.h"
#import "FTPOperation.h"

@interface OperationViewController ()
@property(nonatomic,retain) FTPOperation *ftpOperation;
@end

@implementation OperationViewController
@synthesize urlView;
@synthesize usernameView;
@synthesize passwordView;
@synthesize dirsView;
@synthesize imageView;
@synthesize ftpOperation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Operation", @"Operation");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"Natu" ofType:@"gif"];
    UIImage *anImage = [UIImage imageWithContentsOfFile:aPath];
    self.imageView.image = anImage;
    self.urlView.text = @"ftp://192.168.24.62/Documents/";
    self.dirsView.text = @"000/1202";
    self.usernameView.text = @"kuroki";
    self.passwordView.text = @"";
}

- (void)viewDidUnload
{
    [self setUrlView:nil];
    [self setUsernameView:nil];
    [self setPasswordView:nil];
    [self setDirsView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark textfield

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark actions

- (IBAction)goAction:(id)sender {
    self.ftpOperation = [[FTPOperation alloc] init];
    self.ftpOperation.delegate = self;
    self.ftpOperation.username = self.usernameView.text;
    self.ftpOperation.password = self.passwordView.text;
    self.ftpOperation.baseURL = self.urlView.text;
    [self.ftpOperation dirsFromString:self.dirsView.text];
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"Natu" ofType:@"gif"];
    self.ftpOperation.filePath = aPath;
    [self.ftpOperation run];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)ftpOperationDidChangeStatus:(NSInteger)status
{
    NSLog(@"%s %d",__func__,status);
    switch (status) {
        case kFTPOperationCheckDirs:
        case kFTPOperationCreateDirs:
        case kFTPOperationPutFile:
            break;
            
        default:
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.ftpOperation.delegate = nil;
            self.ftpOperation = nil;
            break;
    }
}

@end
