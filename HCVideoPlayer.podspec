Pod::Spec.new do |spec|
  spec.name         = "HCVideoPlayer"
  spec.version      = "0.0.4"
  spec.summary      = "iOS播放器"
  spec.description  = "支持各种投屏、贴片等各种广告、弹幕等，功能全面"
  spec.homepage     = "https://github.com/chenhongchen/HCVideoPlayer"
  spec.license      = "MIT"
  spec.author             = { "chenhongchen666" => "412130100@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/chenhongchen/HCVideoPlayer.git", :tag => "#{spec.version}" }
  
  spec.source_files  = "HCVideoPlayer/**/*.{h,m}"
  spec.public_header_files = 'HCVideoPlayer/**/*.h'
  spec.resource = "HCVideoPlayer/HCVideoPlayer.bundle","HCVideoPlayer/Lib/BrightnessVolumeView/resource.bundle"
  
  spec.dependency 'MJExtension'
  spec.dependency 'SDWebImage'
  spec.dependency 'FLAnimatedImage'
  spec.dependency 'Reachability'
  spec.dependency 'Peer5Kit', '1.3.6'
  spec.dependency 'google-cast-sdk', '~> 4.4.6'
  spec.dependency 'smart-view-sdk', '2.5.8'
  spec.dependency 'XCDYouTubeKit', '2.8.2'
  spec.dependency 'HCVideoPlayerTools', '0.0.5'
  spec.dependency 'CocoaAsyncSocket'
  
  #引入xml2
  spec.libraries = 'icucore', 'c++', 'z', 'xml2'
  spec.xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'HEADER_SEARCH_PATHS' => '${SDKROOT}/usr/include/libxml2',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'VALID_ARCHS' => 'x86_64 armv7 arm64'
  }
  spec.requires_arc = true
  non_arc_files = 'HCVideoPlayer/Lib/CLUPnP/GData/*.{h,m}'
  spec.exclude_files = non_arc_files
  spec.subspec 'no-arc' do |sp|
    sp.source_files = non_arc_files
    sp.public_header_files = 'HCVideoPlayer/Lib/CLUPnP/GData/*.h'
    sp.requires_arc = false
  end
end
