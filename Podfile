platform :ios, "7.0"

pod 'KVOController'

target :GreatReaderTests do
    pod 'OCMock', '~> 3.0'
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Pods-Acknowledgements.plist', 'GreatReader/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end