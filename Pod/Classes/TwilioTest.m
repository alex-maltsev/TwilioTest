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

@property (nonatomic) void (^completionHandler)(NSData *logData, NSError *error);
@property (nonatomic) BOOL testIsInProgress;

@property (nonatomic) BOOL twilioCallAttempted;
@property (nonatomic, strong) NSString *logFilePath;
@property (nonatomic) FILE *logFilePointer;
@property (nonatomic) int savedStdErr;

@end

@implementation TwilioTest

- (void)performTestWithCompletionHandler:(void (^)(NSData *logData, NSError *error))handler
{
    // Prevent re-entry while test is in progress
    if (self.testIsInProgress) return;
    
    self.testIsInProgress = YES;
    
    self.completionHandler = handler;

    // Doing some cleanup, to handle multiple calls to this function
    self.logFilePath = nil;
    self.logFilePointer = nil;
    self.twilioCallAttempted = NO;
    
    [self performSelectorInBackground:@selector(fetchTwilioTestPage) withObject:nil];
    
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:4
                                                    target:self
                                                  selector:@selector(pageFetchTimedOut)
                                                  userInfo:nil
                                                   repeats:NO];
}


- (void)pageFetchTimedOut
{
    [self finishTestWithError:[self makeErrorWithCode:TwilioTestPageFetchTimedOut]];
}


- (void)finishTestWithError:(NSError *)error
{
    if (timeoutTimer) {
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
    
    NSData *logData;
    
    if (self.twilioCallAttempted) {
        // Stop recording console output before performing disconnect
        [self stopRedirectingConsoleLogToFile];
        
        [[TwilioClient sharedInstance] setLogLevel:TC_LOG_WARN];
        [twilioConnection disconnect];
        
        logData = [NSData dataWithContentsOfFile:self.logFilePath];
    }
    
    self.testIsInProgress = NO;
    
    // Calling completion handler on the UI thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionHandler(logData, error);
    });
}


- (void)fetchTwilioTestPage
{
    NSData *pageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://clientsupport.twilio.com"]];
    
    // Handle the situation of timeout while fetching the page
    if (!self.testIsInProgress) return;
    
    [timeoutTimer invalidate];
    timeoutTimer = nil;
    
    if (pageData == nil) {
        [self finishTestWithError:[self makeErrorWithCode:TwilioTestPageFetchFailed]];
        return;
    }
    
    // Trying to get the capability token out of the page
    NSString *token = [self twilioTokenFromPageData:pageData];
    if (token == nil) {
        [self finishTestWithError:[self makeErrorWithCode:TwilioTestNoTokenFound]];
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
    self.twilioCallAttempted = YES;
    
    [self redirectConsoleLogToFile];
    
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
    [self finishTestWithError:[self makeErrorWithCode:TwilioTestConnectionTimedOut]];
}


#pragma mark - Capturing the log

- (void)redirectConsoleLogToFile
{
    // Saving reference to StdErr
    self.savedStdErr = dup(STDERR_FILENO);
    
    // Switching StdErr to output into file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.logFilePath = [documentsDirectory stringByAppendingPathComponent:@"twilio_test.log"];
    self.logFilePointer = freopen([self.logFilePath fileSystemRepresentation], "w+", stderr);
}


- (void)stopRedirectingConsoleLogToFile
{
    fflush(self.logFilePointer);
    fclose(self.logFilePointer);
    
    // Switching log output back to console
    fflush(stderr);
    dup2(self.savedStdErr, STDERR_FILENO);
    close(self.savedStdErr);
}


#pragma mark - TCConnectionDelegate

- (void)connectionDidConnect:(TCConnection *)connection
{
    [self finishTestWithError:nil];
}


- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error
{
    [self finishTestWithError:[self makeErrorWithCode:TwilioTestConnectionFailed andExtraError:error]];
}


#pragma mark - Preparing specific errors

- (NSError *)makeErrorWithCode:(TwilioTestError)errorCode
{
    return [self makeErrorWithCode:errorCode andExtraError:nil];
}


- (NSError *)makeErrorWithCode:(TwilioTestError)errorCode andExtraError:(NSError *)extraError
{
    NSString *description;
    
    switch (errorCode) {
        case TwilioTestPageFetchTimedOut:
            description = @"Attempt to fetch Twilio test page timed out";
            break;
            
        case TwilioTestPageFetchFailed:
            description = @"Unable to fetch Twilio test page";
            break;

        case TwilioTestNoTokenFound:
            description = @"Unable to obtain token from Twilio test page";
            break;

        case TwilioTestConnectionTimedOut:
            description = @"Connection attempt timed out";
            break;

        case TwilioTestConnectionFailed:
            description = @"Connection failed with error";
            break;
            
        default:
            return nil;
    }
    
    if (extraError) {
        description = [NSString stringWithFormat:@"%@: %@", description, extraError.localizedDescription];
    }
    
    return [NSError errorWithDomain:TwilioTestErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey : description }];
}

@end
