# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'
install! 'cocoapods', :deterministic_uuids => false




target 'EZYGO Rider' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'ACFloatingTextfield-Swift'
  pod 'TransitionButton'
  pod 'IQKeyboardManagerSwift'
  pod 'CHIPageControl'
  pod 'GoogleMaps', '3.0.3'
  pod 'GooglePlaces', '3.0.3'
  pod 'Alamofire'
  pod 'Socket.IO-Client-Swift'
  # pod 'SideMenu'
  pod 'NVActivityIndicatorView'
#  pod 'Fabric'
#  pod 'Crashlytics'
  pod 'SDWebImage', '~> 4.0'
  pod 'M13Checkbox'
  pod 'SideMenuController'
  pod "Pulsator"
  pod 'CardIO'
#  pod 'ACProgressHUD-Swift'
  pod 'CreditCardForm'
  pod 'FormTextField'
  pod 'ActionSheetPicker-3.0'
  pod 'GoogleAnalytics'
 # pod 'FacebookCore'
 # pod 'FacebookLogin'
 # pod 'FacebookShare'
 #  pod 'FacebookSDK'
 pod 'FacebookSDK','5.15.1'
 pod 'FacebookSDK/LoginKit','5.15.1'
 pod 'FacebookSDK/ShareKit','5.15.1'
  pod 'GoogleSignIn'
  # pod 'WWCalendarTimeSelector'
  pod 'DOAlertController', :git => 'https://github.com/okmr-d/DOAlertController.git', :branch => 'master'
  # Pods for TickTok User
#  pod 'GoogleAnalytics'

pod 'Firebase/Analytics', '8.1.0'
pod 'Firebase/Crashlytics'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings["ONLY_ACTIVE_ARCH"] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
