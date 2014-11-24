source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "7.0"

pod 'KVOController'

target :GreatReaderTests do
    pod 'OCMock', '~> 3.0'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'GreatReader/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
