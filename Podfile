source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "7.0"

def common_pods
  pod 'KVOController'
end

target :GreatReader do
  common_pods
end

target :GreatReaderTests do
  common_pods
  pod 'OCMock', '~> 3.0'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-GreatReader/Pods-GreatReader-acknowledgements.plist', 'GreatReader/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
