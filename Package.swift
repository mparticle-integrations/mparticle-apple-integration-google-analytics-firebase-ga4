// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mParticle-Google-Analytics-Firebase-GA4",
    platforms: [ .iOS(.v11) ],
    products: [
        .library(
            name: "mParticle-Google-Analytics-Firebase-GA4",
            targets: ["mParticle-Google-Analytics-Firebase-GA4"]),
    ],
    dependencies: [
      .package(name: "mParticle-Apple-SDK",
               url: "https://github.com/mParticle/mparticle-apple-sdk",
               .upToNextMajor(from: "8.0.0")),
      .package(name: "Firebase",
               url: "https://github.com/firebase/firebase-ios-sdk.git",
               .upToNextMajor(from: "10.6.0")),
    ],
    targets: [
        .target(
            name: "mParticle-Google-Analytics-Firebase-GA4",
            dependencies: [
              .byName(name: "mParticle-Apple-SDK"),
              .product(name: "FirebaseAnalytics", package: "Firebase"),
            ],
            path: "mParticle-Google-Analytics-Firebase-GA4",
            exclude: ["Info.plist"],
            publicHeadersPath: "."),
    ]
)
