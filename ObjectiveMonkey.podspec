Pod::Spec.new do |s|
  s.name             = 'ObjectiveMonkey'
  s.version          = '0.1.0'
  s.summary          = 'Hot patch for iOS App'
  s.description      = <<-DESC
Hot patch for iOS App
                       DESC
  s.homepage         = 'https://github.com/saiten/ObjectiveMonkey'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'saiten' => 'saiten@isidesystem.net' }
  s.source           = { :git => 'https://github.com/saiten/ObjectiveMonkey.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/saiten'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ObjectiveMonkey/**/*'
  s.frameworks = 'JavascriptCore'
end
