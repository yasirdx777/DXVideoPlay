#
# Be sure to run `pod lib lint DXVideoPlay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DXVideoPlay'
  s.version          = '1.0.0'
  s.summary          = 'DXVideoPlay It is a complete video player that supports playlist, subtitles..etc'
  

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'DXVideoPlay It is a complete video player that supports playlist, subtitles..etc, And you can integrate it easily with your app by supplying the DXVideoPlay VC with DXPlayerModel struct which you need to set the needed data for playlist asset items then just present DXVideoPlay VC and you are set to go.'

  s.homepage         = 'https://github.com/yasirdx777/DXVideoPlay'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yasirdx777' => 'yasir.romaya@gmail.com' }
  s.source           = { :git => 'https://github.com/yasirdx777/DXVideoPlay.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/yasirdx777'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*.swift'
  
  s.swift_version = '5.0'
  
  s.platforms = {"ios": "11.0"}
  
  # s.resource_bundles = {
  #   'DXVideoPlay' => ['DXVideoPlay/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit'
end
