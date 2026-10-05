import ProjectDescription

let project = Project(
    name: "EZHeartZones",
    targets: [
        .target(
            name: "EZHeartZones",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.ezheartzones.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
                "ITSAppUsesNonExemptEncryption": false,
                "CFBundleDisplayName": "Heart Zones",
                "NSHealthShareUsageDescription": "Heart Zones reads your heart rate data to calculate how much time you spend in each heart rate zone.",
                "NSHealthUpdateUsageDescription": "Heart Zones does not write data to Health, but this permission may be requested by the system.",
            ]),
            sources: ["Sources/EZHeartZones/**"],
            resources: ["Resources/**"],
            entitlements: "Sources/EZHeartZones/EZHeartZones.entitlements",
            dependencies: [],
            settings: .settings(base: [
                "CODE_SIGN_STYLE": "Automatic",
                "DEVELOPMENT_TEAM": "79KXB9K5XT",
                // Bump MARKETING_VERSION per App Store release. scripts/release.sh overrides
                // CURRENT_PROJECT_VERSION with a timestamp so every upload gets a unique build number.
                "MARKETING_VERSION": "1.0",
                "CURRENT_PROJECT_VERSION": "1",
            ])
        ),
        .target(
            name: "EZHeartZonesTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.ezheartzones.app.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/EZHeartZonesTests/**"],
            dependencies: [.target(name: "EZHeartZones")]
        ),
    ]
)
