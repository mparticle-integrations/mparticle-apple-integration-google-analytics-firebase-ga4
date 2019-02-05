Pod::Spec.new do |s|
    s.name             = "mParticle-Google-Analytics-Firebase"
    s.version          = "7.8.0"
    s.summary          = "Google Analytics for Firebase integration for mParticle"

    s.description      = <<-DESC
                       This is the Google Analytics for Firebase integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-google-analytics-firebase.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"
    s.static_framework = true

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-Google-Analytics-Firebase/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.8.0'
    s.ios.frameworks = 'CoreTelephony', 'SystemConfiguration'
    s.libraries = 'z'
    s.ios.dependency 'Firebase/Core', '~> 5.16.0'

end
