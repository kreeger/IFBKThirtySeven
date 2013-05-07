Pod::Spec.new do |s|
  s.name         = 'BDKThirtySeven'
  s.version      = '0.0.2'
  s.summary      = "A collection of API adapters for some of 37Signal's services."
  s.homepage     = 'https://github.com/kreeger/BDKThirtySeven'
  s.license      = { :type => 'MIT', :file => 'license.markdown' }
  s.author       = { 'Ben Kreeger' => 'ben@kree.gr' }
  s.source       = { :git => 'https://github.com/kreeger/BDKThirtySeven.git', :tag => 'v0.0.2' }
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  # s.frameworks   = 'SystemConfiguration', 'MobileCoreServices'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 1.2'
  s.dependency 'ISO8601DateFormatter', '~> 0.6'
end
