// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.7"

let frameworks = ["ffmpegkit": "0d3291b86b785b1602d5b446e775fce4d2cc8918b6f8a5fa1c1004bab878340c", "libavcodec": "0f2a90827ef82fbcdf01d338f5fe3876adebba6b6b4f2b19b9827970e05a59cb", "libavdevice": "d64df47dd2e8d66709fbb3f9df8c1b6c704b818b57f4448c072fc7d7e7824140", "libavfilter": "050e8b84c4c7659a8685ec078a69a3ad796bbf732eb517baebc2a2597aaba996", "libavformat": "1d758ea368cf38d4c83a1e5d2024820b77ac7ba2170e4c5b8d6f169c4c6ae3b2", "libavutil": "d50c917198e9cc24f68052571a2a02f098cb6e2e86ac41652c81e14941faf033", "libswresample": "d3665c6f3189a01b6ee09a356caf60596cedea06e9f0cb83568170766ccd4d97", "libswscale": "202fef8a54a14397601244b6666f32bd9dc926de26dad9fbea7680ed80af022d"]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/davidmoore1/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv")
]

let libAVFrameworks = frameworks.filter({ $0.key != "ffmpegkit" })

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) }
)
