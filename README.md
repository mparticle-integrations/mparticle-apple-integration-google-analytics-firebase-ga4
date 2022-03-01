## Firebase for Google Analytics 4 (GA4) Kit Integration

This repository contains the [Firebase for GA4](https://firebase.google.com/docs/analytics/get-started?platform=ios)  integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Adding the integration

1. Add the kit dependency to your app's Podfile:

    ```
    pod 'mParticle-Google-Analytics-Firebase-GA4', '~> 8.0'
    ```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { Firebase Analytics GA4 }"` in your Xcode console 

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

### Documentation

[Firebase for GA4 integration](http://docs.mparticle.com/integrations/google-analytics-4/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)