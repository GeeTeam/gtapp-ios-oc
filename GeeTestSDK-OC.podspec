#
# Be sure to run `pod lib lint gtapp-ios-oc.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GeeTestSDK-OC'
  s.version          = '2.16.9.21.1'
  s.summary          = 'GeeTestSDK for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  GeeTestSDK for iOS platform.
                       DESC

  s.homepage         = 'http://www.geetest.com/'
  s.license          = { :type => "Copyright", :text => "武汉极意网络科技有限公司 版权所有." }
  s.author           = { "GeeTeam" => "http://www.geetest.com/" }
  s.source           = { :git => 'https://github.com/GeeTeam/gtapp-ios-oc.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
 
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.frameworks        = 'WebKit'

  s.default_subspec   = 'Core'
  s.subspec "Core" do |core|
    core.vendored_frameworks = 'GTFramework.framework'
  end
  s.subspec "Bitcode" do |bitcode|
    bitcode.vendored_frameworks = 'GTFramework.framework'
  end
end
