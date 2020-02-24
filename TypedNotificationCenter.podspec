Pod::Spec.new do |s|
    s.name = 'TypedNotificationCenter'
    s.version = '1.5.0'
    s.license = 'MIT'
    s.summary = 'Typed version of Apple\'s NotificationCenter to avoid forgetting setting parameters in the userInfo dictionary and needing to handle not having those parameters.'
    s.homepage = 'https://github.com/Cyberbeni/TypedNotificationCenter'
    s.authors = { 'Benedek Kozma' => 'cyberbeni@gmail.com' }
    s.source = { :git => 'https://github.com/Cyberbeni/TypedNotificationCenter', :tag => 'v1.5.0' }
  
    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '9.0'
    s.watchos.deployment_target = '2.0'
  
    s.swift_versions = ['5.0', '5.1']
  
    s.source_files = 'Source/*.swift'
  
    s.frameworks = 'Foundation'
  end
