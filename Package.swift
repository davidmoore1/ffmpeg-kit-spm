// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.12"

let frameworks = ["ffmpegkit": "7e2f466338513719151bed52f317bb8cf4f9fc3f85176188f9b1581739eae0bc", "libavcodec": "98675cd43eb23520cd869da164aec34044f37b0cc687923cb46dc4383a99e88d", "libavdevice": "5124eb4441cb3a73537783be3d02f43ebb9176020e3c8e1747d7d145da4483ee", "libavfilter": "008c869470f3ad3dec9121ca5be1362860ac3de34597a07a44e1b6e4782089a0", "libavformat": "466858b4e3d35f57002d3464a1d8d49add9da21de1bd8802c12ce4712ac9bd07", "libavutil": "19cc8263b47d157e8d8b2a9f89c109956dfa1fac6caa0b6c2b0de06790b231b9", "libswresample": "f79f053ebe4a196b3ea85c470435d688a9369411a70ca8f999709ceb758383c9", "libswscale": "da109978c27e2db87e8072fe0db014fc3292a20caab1b8aa84d35a7d57af52e8"]

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
