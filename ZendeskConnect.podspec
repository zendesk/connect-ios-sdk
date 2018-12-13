#
# Be sure to run `pod lib lint Connect.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name              = "ZendeskConnect"
  s.version           = "2.0.0"
  s.summary           = "Better Messages for Web and Mobile Apps"
  s.description       = <<-DESC
                        Connect makes it easy to send email and mobile messages based on user actions, then test how much each message helps your business.
                        DESC
  s.homepage          = "https://www.zendesk.com/"
  s.author              = 'Zendesk'
  s.source              = { :git => "https://github.com/zendesk/connect-ios-sdk.git", :tag => s.version.to_s }
  s.documentation_url   = 'https://developer.zendesk.com/embeddables/docs/outbound/ios'
  s.swift_version       = '4.2'

  s.platform            = :ios, '9.0'
  s.requires_arc        = true

  s.source_files        = 'ZendeskConnect/ZendeskConnect/**/*.swift'
  
  s.frameworks          = 'UIKit'
  s.license           = { 
    :type => 'Apache 2.0',
    :file => 'LICENSE'
  }
end
