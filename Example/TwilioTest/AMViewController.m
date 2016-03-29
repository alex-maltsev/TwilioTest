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
        self.emailLogButton.hidden = NO;
        self.logData = logData;
        
        if (error) {
            // TODO: reflect error message
            [self reflectSuccess:NO];
        }
        else {
            [self reflectSuccess:YES];
        }
        
        if (logData.length > 0) {
            NSString *logString = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
            self.logTextView.text = logString;
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
    
    if (self.logData.length > 0) {
        [mc setMessageBody:@"See console log attached" isHTML:NO];
        // Set log file as attachment
        [mc addAttachmentData:self.logData mimeType:@"text/plain" fileName:@"twilio_test.log"];
    }
    else {
        [mc setMessageBody:@"Console log was not captured" isHTML:NO];
    }
    
    [self presentViewController:mc animated:YES completion:NULL];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
