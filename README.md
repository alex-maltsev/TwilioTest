# TwilioTest

[![Version](https://img.shields.io/cocoapods/v/TwilioTest.svg?style=flat)](http://cocoapods.org/pods/TwilioTest)
[![License](https://img.shields.io/cocoapods/l/TwilioTest.svg?style=flat)](http://cocoapods.org/pods/TwilioTest)
[![Platform](https://img.shields.io/cocoapods/p/TwilioTest.svg?style=flat)](http://cocoapods.org/pods/TwilioTest)

## Description
Twilio sometimes refuses to work due to particular network settings issues of an app user (typically WiFi router blocking [something essential](https://www.twilio.com/help/faq/twilio-client/what-are-twilio-clients-network-connectivity-requirements)). This can be notoriously difficult to diagnose when you can't rely on technical savvy of the affected user. This project provides you with a way to build a Twilio diagnostics feature into your app, such that you will be able to intercept verbose logs of Twilio's attempt to establish a call.

## Installation

TwilioTest is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TwilioTest"
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Initialization

```objectivec
#import <TwilioTest\TwilioTest.h>

TwilioTest twilioTest = [[TwilioTest alloc] init];

// Adjust timeouts if desired
twilioTest.testPageFetchTimeout = 5; // Timeout for fetching Twilio test page
twilioTest.connectionAttemptTimeout = 30; // Timeout for establishing Twilio call
```

### Test without capability token

TwilioTest can try to grab the Twilio capability token from the Twilio test page http://clientsupport.twilio.com, so you don't need to supply your own token.

```objectivec
[twilioTest performTestWithCompletionHandler:^(NSData *logData, NSError *error) {
	if (error) {
		// NB: 'error' will be of a custom error type (see TwilioTest.h)
		NSLog(@"Twilio test failed with error: %@", error.localizedDescription);
	}
	else {
		NSLog(@"Twilio test passed");
	}

	NSLog(@"Captured console log of length %zd", logData.length);
}];
```

Since the Twilio test page is served over HTTP, you will need to set up a security exception for TwilioTest to work on iOS 9. You can achieve that by adding the following into your Info.plist file:

```xml
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSExceptionDomains</key>
	<dict>
		<key>twilio.com</key>
		<dict>
			<key>NSIncludesSubdomains</key>
			<true/>
			<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
			<true/>
		</dict>
	</dict>
</dict>
```

### Test with your capability token

If you'd rather use your own capability token and connection parameters, you can call the following method instead:

```objectivec
- (void)performTestWithCapabilityToken:(NSString *)token
                            parameters:(NSDictionary *)parameters
                     completionHandler:(void (^)(NSData *logData, NSError *error))handler;
```
Here 'parameters' is the dictionary you would normally pass to `TCDevice connect` function, and can be nil.

## License

TwilioTest is available under the MIT license. See the LICENSE file for more info.
