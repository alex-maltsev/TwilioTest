Pod::Spec.new do |s|
  s.name             = "TwilioTest"
  s.version          = "0.1.2"
  s.summary          = "Utility class for diagnosing Twilio connectivity problems"

  s.description      = <<-DESC
	Twilio sometimes refuses to work due to particular network settings issues of an app user. This project provides you with a way to build a Twilio diagnostics feature into your app, such that you will be able to intercept verbose logs of Twilio's attempt to establish a call.
						DESC
						
  s.homepage         = "https://github.com/alex-maltsev/TwilioTest"
  s.license          = 'MIT'
  s.author           = { "alex-maltsev" => "alex.maltsev@gmail.com" }
  s.source           = { :git => "https://github.com/alex-maltsev/TwilioTest.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'TwilioSDK', '~> 1.2'
  
end
