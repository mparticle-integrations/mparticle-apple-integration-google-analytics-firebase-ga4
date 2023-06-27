Pod::Spec.new do |s|
    s.name             = "mParticle-Google-Analytics-Firebase-GA4"
    s.version          = "8.3.4"
    s.summary          = "Google Analytics 4 for Firebase integration for mParticle"

    s.description      = <<-DESC
                       This is the Google Analytics 4 for Firebase integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-google-analytics-firebase-ga4.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"
    s.static_framework = true

    s.ios.deployment_target = "11.0"
    s.ios.source_files      = 'mParticle-Google-Analytics-Firebase-GA4/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.0'
    s.ios.frameworks = 'CoreTelephony', 'SystemConfiguration'
    s.libraries = 'z'
    s.ios.dependency 'Firebase/Core', '~> 10.6'

    s.tvos.deployment_target = "12.0"
    s.tvos.source_files      = 'mParticle-Google-Analytics-Firebase-GA4/*.{h,m,mm}'
    s.tvos.dependency 'mParticle-Apple-SDK/mParticle', '~> 8.0'
    s.tvos.frameworks = 'SystemConfiguration'
    s.libraries = 'z'
    s.tvos.dependency 'Firebase/Core', '~> 10.6'

end
