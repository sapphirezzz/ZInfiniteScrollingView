#
# Be sure to run `pod lib lint ZInfiniteScrollingView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZInfiniteScrollingView'
  s.version          = '1.2.0'
  s.summary          = 'A short description of ZInfiniteScrollingView.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/sapphirezzz/ZInfiniteScrollingView'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ZackZheng' => 'zhengzuanzhe@gmail.com' }
  s.source           = { :git => 'https://github.com/sapphirezzz/ZInfiniteScrollingView.git', :tag => s.version.to_s }

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'ZInfiniteScrollingView/Classes/**/*'
  s.frameworks = 'UIKit'

end
