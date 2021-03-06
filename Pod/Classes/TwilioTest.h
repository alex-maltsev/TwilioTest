//
//  TwilioTest.h
//  Pods
//
//  Created by Alex Maltsev on 3/28/16.
//
//

#import <Foundation/Foundation.h>

static NSString * const TwilioTestErrorDomain = @"TwilioTestErrorDomain";

typedef enum {
    TwilioTestPageFetchFailed = 100, // Fetching of Twilio's test page failed for some reason
    TwilioTestNoTokenFound, // Fetched the Twilio's test page, but failed to extract capability token from it
    TwilioTestConnectionTimedOut, // Attempt to establish Twilio call timed out
    TwilioTestConnectionFailed // Attempt to establish Twilio call failed for some reason
} TwilioTestError;


@interface TwilioTest : NSObject

// The amount of time after which the attempt to fetch the Twilio test page (http://clientsupport.twilio.com)
// is considered timed out (seconds). Defaults to 4.
@property (nonatomic) NSTimeInterval testPageFetchTimeout;

// The ammount of time after which the attempt to establish Twilio connection
// is considered timed out (seconds). Defaults to 60.
@property (nonatomic) NSTimeInterval connectionAttemptTimeout;

// Test Twilio connection using capability token obtained from the Twilio test page
- (void)performTestWithCompletionHandler:(void (^)(NSData *logData, NSError *error))handler;

// Test Twilio connection using the provided capability token and connection parameters
- (void)performTestWithCapabilityToken:(NSString *)token
                            parameters:(NSDictionary *)parameters
                     completionHandler:(void (^)(NSData *logData, NSError *error))handler;

@end
