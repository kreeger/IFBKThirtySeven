Pod::Spec.new do |s|
  s.name         = 'IFBKThirtySeven'
  s.version      = '0.0.3'
  s.summary      = "A collection of API adapters for some of 37Signal's services."
  s.homepage     = 'https://github.com/kreeger/IFBKThirtySeven'
  s.license      = { :type => 'MIT', :file => 'license.markdown' }
  s.authors      = { 'Ben Kreeger' => 'ben@kree.gr', 'Fabio Pelosin' => 'fabiopelosin@gmail.com' }
  s.source       = { :git => 'https://github.com/kreeger/IFBKThirtySeven.git', :tag => 'v0.0.3' }
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  # s.frameworks   = 'SystemConfiguration', 'MobileCoreServices'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 1.2'
  s.dependency 'SBJson', '~> 3.2'
end
