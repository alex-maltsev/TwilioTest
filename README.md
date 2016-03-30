# TwilioTest

[![CI Status](http://img.shields.io/travis/alex-maltsev/TwilioTest.svg?style=flat)](https://travis-ci.org/alex-maltsev/TwilioTest)
[![Version](https://img.shields.io/cocoapods/v/TwilioTest.svg?style=flat)](http://cocoapods.org/pods/TwilioTest)
[![License](https://img.shields.io/cocoapods/l/TwilioTest.svg?style=flat)](http://cocoapods.org/pods/TwilioTest)
[![Platform](https://img.shields.io/cocoapods/p/TwilioTest.svg?style=flat)](http://cocoapods.org/pods/TwilioTest)

## Description
Twilio sometimes refuses to work due to particular network settings issues of an app user (typically WiFi router blocking something essential). This can be notoriously difficult to diagnose when you can't rely on technical savvy of the affected user. This project provides you with a way to build a Twilio diagnostics feature into your app, such that you will be able to intercept verbose logs of Twilio's attempt to establish a call.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

TwilioTest is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TwilioTest"
```

TwilioTest grabs the Twilio capability token from the Twilio test page http://clientsupport.twilio.com. Since that page is served over HTTP, you will need to set up a security exception for TwilioTest to work on iOS 9. You can achieve that by adding the following into your Info.plist file:

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

## License

TwilioTest is available under the MIT license. See the LICENSE file for more info.
