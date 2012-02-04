//
//  CreateDirectoryViewController.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateDirectoryViewController.h"

@interface CreateDirectoryViewController ()

@property(nonatomic,strong) FTPCreateDirectory *ftpRequest;

@end

@implementation CreateDirectoryViewController
@synthesize urlView;
@synthesize usernameView;
@synthesize passwordView;
@synthesize resultView;
@synthesize nameView;
@synthesize ftpRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Folder", @"Folder");
        self.tabBarItem.image = [UIImage imageNamed:@"Folder"];
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
    self.urlView.text = @"ftp://192.168.24.62/Documents/";
    self.nameView.text = @"untitled";
    self.usernameView.text = @"kuroki";
    self.passwordView.text = @"";
}

- (void)viewDidUnload
{
    [self setUrlView:nil];
    [self setUsernameView:nil];
    [self setPasswordView:nil];
    [self setResultView:nil];
    [self setNameView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark actions

- (IBAction)goAction:(id)sender {
    self.ftpRequest = [[FTPCreateDirectory alloc] init];
    self.ftpRequest.delegate = self;
    self.ftpRequest.username = self.usernameView.text;
    self.ftpRequest.password = self.passwordView.text;
    self.ftpRequest.url = self.urlView.text;
    self.ftpRequest.filePath = self.nameView.text;
    [self.ftpRequest startCreating];
    if ( self.ftpRequest.isRunning ) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

-(void)ftpStatusDidChanged:(enum FTPstatus_enum)status
{
    NSString *aString;
    if ( !self.ftpRequest.isRunning ) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if ( self.ftpRequest.status == kFTPStatusClosed ) {
        aString = [NSString stringWithFormat:@"SUCCESS : Create Directory\n\t%@",self.ftpRequest.url];
    }
    if ( self.ftpRequest.status == kFTPStatusError ) {
        aString = [NSString stringWithFormat:@"FAILED : Create Directory\n\t%@",self.ftpRequest.url];
    }
    if ( aString ) {
        [self.resultView setText:aString];
    }
}

@end
