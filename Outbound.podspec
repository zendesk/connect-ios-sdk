#
# Be sure to run `pod lib lint Outbound.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name              = "Outbound"
  s.version           = "1.0.3"
  s.summary           = "Better Messages for Web and Mobile Apps"
  s.description       = <<-DESC
                        Outbound makes it easy to send email and mobile messages based on user actions, then test how much each message helps your business.
                        DESC
  s.homepage          = "http://www.outbound.io"
  s.license           = { :type => "Commercial", :text => "              All text and design is copyright © 2015 Outbound Solutions, Inc.\n\n              All rights reserved.\n\n              http://www.outbound.io\n" }
  s.author            = { "Dhruv Mehta" => "dhruv@outbound.io" }
  s.source            = { :git => "https://github.com/outboundio/ios-sdk.git", :tag => s.version.to_s }
  s.social_media_url  = 'https://twitter.com/OutboundIO'
  s.documentation_url = 'https://github.com/outboundio/api'

  s.platform          = :ios, '7.0'
  s.requires_arc      = true

  s.source_files       = 'Outbound/*.{h,m}'
  s.prefix_header_file = 'Outbound/Outbound-Prefix.pch'
  
  s.frameworks        = 'UIKit'
end
