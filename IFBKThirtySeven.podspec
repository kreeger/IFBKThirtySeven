Pod::Spec.new do |s|
  s.name         = 'IFBKThirtySeven'
  s.version      = '0.0.4'
  s.summary      = "A collection of API adapters for some of 37Signal's services."
  s.homepage     = 'https://github.com/kreeger/IFBKThirtySeven'
  s.license      = { :type => 'MIT', :file => 'license.markdown' }
  s.authors      = { 'Ben Kreeger' => 'ben@kree.gr', 'Fabio Pelosin' => 'fabiopelosin@gmail.com' }
  s.source       = { :git => 'https://github.com/kreeger/IFBKThirtySeven.git', :tag => "v#{s.version}" }
  s.source_files = 'Classes'
  s.ios.deployment_target = '6.1'
  s.osx.deployment_target = '10.8'
  s.frameworks   = 'SystemConfiguration'
  s.ios.frameworks = 'MobileCoreServices'
  s.osx.frameworks = 'CoreServices'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.0.2'
  s.dependency 'SBJson', '~> 3.2'

  s.subspec 'Models' do |sp|
    sp.source_files = 'Classes/**/*.{h,m}'
  end
end
