// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mParticle-Google-Analytics-Firebase-GA4",
    platforms: [ .iOS(.v13), .tvOS(.v13) ],
    products: [
        .library(
            name: "mParticle-Google-Analytics-Firebase-GA4",
            targets: ["mParticle-Google-Analytics-Firebase-GA4"]),
        .library(
            name: "mParticle-Google-Analytics-Firebase-GA4-NoLocation",
            targets: ["mParticle-Google-Analytics-Firebase-GA4-NoLocation"])
    ],
    dependencies: [
      .package(name: "mParticle-Apple-SDK",
               url: "https://github.com/mParticle/mparticle-apple-sdk",
               .upToNextMajor(from: "8.22.0")),
      .package(name: "Firebase",
               url: "https://github.com/firebase/firebase-ios-sdk.git",
               .upToNextMajor(from: "11.8.0")),
    ],
    targets: [
        .target(
            name: "mParticle-Google-Analytics-Firebase-GA4",
            dependencies: [
              .product(name: "mParticle-Apple-SDK", package: "mParticle-Apple-SDK"),
              .product(name: "FirebaseAnalytics", package: "Firebase"),
            ],
            path: "mParticle-Google-Analytics-Firebase-GA4",
            exclude: ["Info.plist", "dummy.swift"],
            resources: [.process("PrivacyInfo.xcprivacy")],
            publicHeadersPath: "."),
        .target(
            name: "mParticle-Google-Analytics-Firebase-GA4-NoLocation",
            dependencies: [
              .product(name: "mParticle-Apple-SDK-NoLocation", package: "mParticle-Apple-SDK"),
              .product(name: "FirebaseAnalytics", package: "Firebase"),
            ],
            path: "SPM/mParticle-Google-Analytics-Firebase-GA4-NoLocation",
            exclude: ["Info.plist", "dummy.swift"],
            resources: [.process("PrivacyInfo.xcprivacy")],
            publicHeadersPath: "."),
    ]
)
