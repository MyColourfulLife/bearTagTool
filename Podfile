# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'

target 'bearTagTool' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for bearTagTool

  pod 'SnapKit', '~> 3.2.0'

  pod 'SDWebImage'

  pod 'MBProgressHUD'	

  pod 'RealmSwift'

  pod 'Alamofire'

  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
end

