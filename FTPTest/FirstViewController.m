//
//  FirstViewController.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "FTPGetter.h"

@interface FirstViewController ()

@property(nonatomic,strong) FTPGetter *ftpGetter;

@end


@implementation FirstViewController
@synthesize urlView;
@synthesize usernameView;
@synthesize passwordView;
@synthesize resultView;
@synthesize ftpGetter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setUrlView:nil];
    [self setUsernameView:nil];
    [self setPasswordView:nil];
    [self setResultView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.urlView.text = @"ftp://ftp.st.ryukoku.ac.jp/pub/doc/internet/sinet.txt";
    self.urlView.text = @"ftp://192.168.24.62/Documents/README.TXT";
    self.usernameView.text = @"kuroki";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark textfield

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark action

- (IBAction)goAction:(id)sender {
    self.ftpGetter = [[FTPGetter alloc] init];
    self.ftpGetter.delegate = self;
    self.ftpGetter.username = self.usernameView.text;
    self.ftpGetter.password = self.passwordView.text;
    self.ftpGetter.url = self.urlView.text;
    [self.ftpGetter startReceiving];
    if ( self.ftpGetter.isRunning ) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

-(void)ftpStatusDidChanged:(enum FTPstatus_enum)status
{
    if ( !self.ftpGetter.isRunning ) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    if ( self.ftpGetter.status == kFTPStatusClosed ) {
        NSError *error;
        NSString *aString = [NSString stringWithContentsOfFile:self.ftpGetter.filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
        if ( aString ) {
            [self.resultView setText:aString];
        }
    }
}

@end
