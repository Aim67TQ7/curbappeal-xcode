# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'CurbAppeal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CurbAppeal
  
  # Firebase for analytics and remote config
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Crashlytics'
  
  # UI and animations
  pod 'lottie-ios'
  
  # Networking
  pod 'Alamofire', '~> 5.6'
  
  # Image loading and caching
  pod 'Kingfisher', '~> 7.0'
  
  # JSON parsing
  pod 'SwiftyJSON', '~> 4.0'
  
  # KeyChain wrapper
  pod 'KeychainAccess'
  
  # UI components
  pod 'SVProgressHUD'
  
  # Auto Layout helpers
  pod 'SnapKit', '~> 5.0.0'

  target 'CurbAppealTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CurbAppealUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
    end
  end
end