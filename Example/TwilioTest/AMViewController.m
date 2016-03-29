//
//  AMViewController.m
//  TwilioTest
//
//  Created by Alex Maltsev on 03/28/2016.
//  Copyright (c) 2016 Alex Maltsev. All rights reserved.
//

#import "AMViewController.h"
#import <TwilioTest/TwilioTest.h>
#import <MessageUI/MessageUI.h>

@interface AMViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) TwilioTest *twilioTest;
@property (strong, nonatomic) NSData *logData;
@property (strong, nonatomic) NSError *testError;

@property (weak, nonatomic) IBOutlet UIButton *startTestButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *emailResultsButton;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

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
    self.emailResultsButton.hidden = YES;
    self.errorMessageLabel.hidden = YES;
    self.logTextView.text = @"Captured console log will appear here";
}


- (IBAction)startTestPressed:(id)sender
{
    [self.indicator startAnimating];
    self.startTestButton.enabled = NO;
    [self resetUI];
    
    [self.twilioTest performTestWithCompletionHandler:^(NSData *logData, NSError *error) {
        [self.indicator stopAnimating];
        self.startTestButton.enabled = YES;
        self.emailResultsButton.hidden = NO;
        self.logData = logData;
        self.testError = error;
        
        if (error) {
            self.errorMessageLabel.hidden = NO;
            self.errorMessageLabel.text = error.localizedDescription;
            [self reflectSuccess:NO];
        }
        else {
            [self reflectSuccess:YES];
        }
        
        if (logData.length > 0) {
            NSString *logString = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
            self.logTextView.text = logString;
        }
        else {
            self.logTextView.text = @"Console log was not captured";
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


- (IBAction)emailResultsPressed:(id)sender
{
    // Make sure that we can send emails
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:@"Sorry, you need to set up your email app first"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    NSArray *recipents = [NSArray arrayWithObject:@"support@yourcompany.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Twilio test report"];
    [mc setToRecipients:recipents];
    
    // Create email body, reflecting whether the test passed and whether log was captured
    NSMutableString *message = [NSMutableString string];
    if (self.testError) {
        [message appendFormat:@"Test failed. %@", self.testError.localizedDescription];
    }
    else {
        [message appendString:@"Test passed"];
    }
    
    if (self.logData.length > 0) {
        [message appendString:@"\n\nSee console log attached"];
        // Set log file as attachment
        [mc addAttachmentData:self.logData mimeType:@"text/plain" fileName:@"twilio_test.log"];
    }
    else {
        [message appendString:@"\n\nConsole log was not captured"];
    }

    [mc setMessageBody:message isHTML:NO];

    [self presentViewController:mc animated:YES completion:NULL];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
