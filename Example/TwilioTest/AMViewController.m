//
//  AMViewController.m
//  TwilioTest
//
//  Created by Alex Maltsev on 03/28/2016.
//  Copyright (c) 2016 Alex Maltsev. All rights reserved.
//

#import "AMViewController.h"
#import <TwilioTest/TwilioTest.h>

@interface AMViewController ()

@property (strong, nonatomic) TwilioTest *twilioTest;

@property (weak, nonatomic) IBOutlet UIButton *startTestButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *emailLogButton;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;

@end

@implementation AMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Init the test object
    self.twilioTest = [[TwilioTest alloc] init];
    
    // Set up UI
    self.logTextView.layer.cornerRadius = 4;
    self.logTextView.layer.borderWidth = 1;
    self.logTextView.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
    
    [self resetUI];
}


- (void)resetUI
{
    self.successLabel.hidden = YES;
    self.emailLogButton.hidden = YES;
    self.logTextView.text = @"";
}


- (IBAction)startTestPressed:(id)sender
{
    [self.indicator startAnimating];
    self.startTestButton.enabled = NO;
    [self resetUI];
    
    [self.twilioTest performTestWithCompletionHandler:^(NSData *logData, NSError *error) {
        [self.indicator stopAnimating];
        self.startTestButton.enabled = YES;
        
        if (error) {
            // TODO: reflect error message
            [self reflectSuccess:NO];
        }
        else {
            [self reflectSuccess:YES];
        }
        
        if (logData) {
            NSString *logString = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
            self.logTextView.text = logString;
            self.emailLogButton.hidden = NO;
        }
    }];
}


- (void)reflectSuccess:(BOOL)success
{
    self.successLabel.hidden = NO;
    
    if (success) {
        self.successLabel.text = @"Test Passed";
        self.successLabel.textColor = [UIColor greenColor];
    }
    else {
        self.successLabel.text = @"Test Failed";
        self.successLabel.textColor = [UIColor redColor];
    }
}


- (IBAction)emailLogPressed:(id)sender
{
}



@end
