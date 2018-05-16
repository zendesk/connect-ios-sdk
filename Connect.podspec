#
# Be sure to run `pod lib lint Connect.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name              = "Connect"
  s.version           = "1.1.0"
  s.summary           = "Better Messages for Web and Mobile Apps"
  s.description       = <<-DESC
                        Connect makes it easy to send email and mobile messages based on user actions, then test how much each message helps your business.
                        DESC
  s.homepage          = "https://www.zendesk.com/"
  s.license           = { 
    :type => 'Commercial', 
    :text => <<-LICENSE
    Copyright (c) 2017 Zendesk. All rights reserved.
    By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
    Subscription Agreement https://www.zendesk.com/company/customers-partners/#master-subscription-agreement and Application Developer and API License
    Agreement https://www.zendesk.com/company/customers-partners/#application-developer-api-license-agreement and
    acknowledge that such terms govern Your use of and access to the Mobile SDK.
    LICENSE
  }
  s.author            = 'Zendesk'
  s.source            = { :git => "https://github.com/zendesk/connect-ios-sdk.git", :tag => s.version.to_s }
  s.documentation_url = 'https://developer.zendesk.com/embeddables/docs/connect/introduction'

  s.platform          = :ios, '8.0'
  s.requires_arc      = true

  s.source_files       = 'Outbound/*.{h,m}'
  s.prefix_header_file = 'Outbound/Outbound-Prefix.pch'
  
  s.frameworks        = 'UIKit'
end
