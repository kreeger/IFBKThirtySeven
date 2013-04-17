Pod::Spec.new do |s|
  s.name         = 'BDKThirtySeven'
  s.version      = '0.0.1'
  s.summary      = "A collection of API adapters for some of 37Signal's services."
  s.homepage     = 'https://github.com/kreeger/BDKThirtySeven'
  s.license      = { :type => 'MIT', :file => 'license.markdown' }
  s.author       = { 'Ben Kreeger' => 'ben@kree.gr' }
  s.source       = { :git => 'git://github.com/kreeger/BDKThirtySeven', :tag => '0.0.1' }
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  s.requires_arc = true

  s.dependency 'SBJson', '~> 3.2'
  s.dependency 'AFNetworking', '~> 1.2'
  s.dependency 'ObjectiveSugar', '~> 0.6.2'
end
