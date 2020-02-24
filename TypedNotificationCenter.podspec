Pod::Spec.new do |s|
    s.name = 'TypedNotificationCenter'
    s.version = '1.5.0'
    s.license = 'MIT'
    s.summary = 'Swiftier version of Apple\'s NotificationCenter.'
    s.homepage = 'https://github.com/Cyberbeni/TypedNotificationCenter'
    s.authors = { 'Benedek Kozma' => 'cyberbeni@gmail.com' }
    s.source = { :git => 'https://github.com/Cyberbeni/TypedNotificationCenter.git', :tag => s.version }
  
    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.10'
    s.tvos.deployment_target = '9.0'
    s.watchos.deployment_target = '2.0'
  
    s.swift_versions = ['5.0', '5.1', '5.1.3']
  
    s.source_files = 'Sources/TypedNotificationCenter/**/*.swift'
  
    s.frameworks = 'Foundation'
  end