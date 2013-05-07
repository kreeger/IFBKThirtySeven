Pod::Spec.new do |s|
  s.name         = 'BDKThirtySeven'
  s.version      = '0.0.2'
  s.summary      = "A collection of API adapters for some of 37Signal's services."
  s.homepage     = 'https://github.com/kreeger/BDKThirtySeven'
  s.license      = { :type => 'MIT', :file => 'license.markdown' }
  s.author       = { 'Ben Kreeger' => 'ben@kree.gr' }
  s.source       = { :git => 'git://github.com/kreeger/BDKThirtySeven', :tag => 'v0.0.2' }
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  # s.frameworks   = 'SystemConfiguration', 'MobileCoreServices'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 1.2'
end
