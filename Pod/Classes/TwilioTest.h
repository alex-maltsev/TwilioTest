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
    TwilioTestPageFetchTimedOut = 100, // Timed out while trying to fetch Twilio's test page
    TwilioTestPageFetchFailed, // Fetching of Twilio's test page failed for some reason
    TwilioTestNoTokenFound, // Fetched the Twilio's test page, but failed to extract capability token from it
    TwilioTestConnectionTimedOut, // Attempt to establish Twilio call timed out
    TwilioTestConnectionFailed // Attempt to establish Twilio call failed for some reason
} TwilioTestError;


@interface TwilioTest : NSObject

- (void)performTestWithCompletionHandler:(void (^)(NSData *logData, NSError *error))handler;

@end
