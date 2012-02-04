//
//  SecondViewController.m
//  FTPTest
//
//  Created by 黒木 政幸 on 12/02/01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property(nonatomic,strong) FTPPutter *ftpPutter;

@end

@implementation SecondViewController

@synthesize urlView;
@synthesize usernameView;
@synthesize passwordView;
@synthesize imageView;
@synthesize ftpPutter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
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
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"Natu" ofType:@"gif"];
    UIImage *anImage = [UIImage imageWithContentsOfFile:aPath];
    self.imageView.image = anImage;
    self.urlView.text = @"ftp://192.168.24.62/Documents/";
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
    self.ftpPutter = [[FTPPutter alloc] init];
    self.ftpPutter.delegate = self;
    self.ftpPutter.username = self.usernameView.text;
    self.ftpPutter.password = self.passwordView.text;
    self.ftpPutter.url = self.urlView.text;
    NSString *aPath = [[NSBundle mainBundle] pathForResource:@"Natu" ofType:@"gif"];
    self.ftpPutter.filePath = aPath;
    [self.ftpPutter startSending];
    if ( self.ftpPutter.isRunning ) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

-(void)ftpStatusDidChanged:(enum FTPstatus_enum)status
{
    if ( !self.ftpPutter.isRunning ) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
