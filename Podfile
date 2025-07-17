source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'
use_frameworks!

target 'csnews' do
    pod 'NVActivityIndicatorView', '~> 5.2.0'
    pod 'Kingfisher', '~> 8.5.0'
    pod 'Contentstack', '~> 3.15.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  
    # Remove _CodeSignature from all frameworks (fixes rsync sandbox error)
    Dir.glob('Pods/**/*.framework/_CodeSignature').each do |code_signature|
      FileUtils.rm_rf(code_signature)
    end
  end
