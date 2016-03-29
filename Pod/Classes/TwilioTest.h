//
//  TwilioTest.h
//  Pods
//
//  Created by Alex Maltsev on 3/28/16.
//
//

#import <Foundation/Foundation.h>

@interface TwilioTest : NSObject

@property (nonatomic, strong) NSString *errorMessage;

- (void)performTestWithCompletionHandler:(void (^)(NSData *logData, NSError *error))handler;

@end
