//
//  TwilioTest.m
//  Pods
//
//  Created by Alex Maltsev on 3/28/16.
//
//

#import "TwilioTest.h"
#import <TwilioSDK/TwilioClient.h>

@interface TwilioTest() <TCConnectionDelegate>
{
    TCDevice *twilioDevice;
    TCConnection *twilioConnection;
    NSTimer *timeoutTimer;
}

@end

@implementation TwilioTest

- (void)startConditionally
{
    [self performSelectorInBackground:@selector(fetchTwilioTestPage) withObject:nil];
    
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:4
                                                    target:self
                                                  selector:@selector(pageFetchTimedOut)
                                                  userInfo:nil
                                                   repeats:NO];
}


- (void)pageFetchTimedOut
{
    [self finishTestWithSuccess:NO errorMessage:@"Unable to fetch Twilio test page. Request timed out."];
}


- (void)finishTestWithSuccess:(BOOL)succeeded errorMessage:(NSString *)errorMessage
{
    if (timeoutTimer) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
    
    self.completedSuccessfully = succeeded;
    self.errorMessage = errorMessage;
    [twilioConnection disconnect];
    
    [[TwilioClient sharedInstance] setLogLevel:TC_LOG_WARN];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      //  [self.delegate diagnosticsTest:self didCompleteWithSuccess:succeeded];
    });
}


- (void)fetchTwilioTestPage
{
    NSData *pageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://clientsupport.twilio.com"]];
    
    // Handle the situation of timeout while fetching the page
    if (self.errorMessage) return;
    
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    if (pageData == nil) {
        [self finishTestWithSuccess:NO errorMessage:@"Unable to fetch Twilio test page"];
        return;
    }
    
    // Trying to get the capability token out of the page
    NSString *token = [self twilioTokenFromPageData:pageData];
    if (token == nil) {
        [self finishTestWithSuccess:NO errorMessage:@"Unable to obtain token from test page"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startConnectionWithToken:token];
    });
}


- (NSString *)twilioTokenFromPageData:(NSData *)pageData
{
    NSString *pageString = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
    
    // Extracting token from the statement: Twilio.Device.setup("[token]", {'debug':true});
    // So token is the string between 'Twilio.Device.setup("' and the next nearest quotation mark
    NSString *keyString = @"Twilio.Device.setup(\"";
    NSRange keyRange = [pageString rangeOfString:keyString];
    if (keyRange.location == NSNotFound) {
        return nil;
    }
    
    NSRange closingQuoteRange = [pageString rangeOfString:@"\"" options:0 range:NSMakeRange(keyRange.location + keyRange.length, 400)];
    NSRange tokenRange = NSMakeRange(keyRange.location + keyRange.length, closingQuoteRange.location - keyRange.location - keyRange.length);
    
    return [pageString substringWithRange:tokenRange];
}


- (void)startConnectionWithToken:(NSString *)token
{
    [[TwilioClient sharedInstance] setLogLevel:TC_LOG_DEBUG];
    
    twilioDevice = [[TCDevice alloc] initWithCapabilityToken:token delegate:nil];
    twilioConnection = [twilioDevice connect:@{} delegate:self];
    
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                    target:self
                                                  selector:@selector(connectionTimedOut)
                                                  userInfo:nil
                                                   repeats:NO];
}


- (void)connectionTimedOut
{
    if (!self.completedSuccessfully) {
        [self finishTestWithSuccess:NO errorMessage:@"Connection attempt timed out"];
    }
}


#pragma mark - TCConnectionDelegate

- (void)connectionDidConnect:(TCConnection *)connection
{
    [self finishTestWithSuccess:YES errorMessage:nil];
}


- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error
{
    [self finishTestWithSuccess:NO errorMessage:[NSString stringWithFormat:@"Connection failed with error: %@", error.localizedDescription]];
}

@end
