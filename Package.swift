// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.3.1"

let frameworks = ["ffmpegkit": "5cf9f257fd6f91907737603c1061c1b592540c66413afd11e1b1661f5780186c", "libavcodec": "077cfc9564fabef4b76f0542b957baa8e79e563f7042178d4fb64615c92cc27d", "libavdevice": "659953c2d67739494e7ba26b7bb02f05040dab8f68dd05d64de6177a3dc02239", "libavfilter": "f151e60151db96e264c9a4c8f881db868508bbb7c6fb27da3c8757b800c3b298", "libavformat": "0fb866841960b6f97277e1c424c514af7b32cd0bc5adcc2c7324bf28d0ba6685", "libavutil": "9348723276519edd7ed0ab9a21c69ec3449add81c7c0434c1477c8855ae44659", "libswresample": "28cf39224dd0cfb142cb1dd9e1f55acc18e6236547bbda18da2e725701246518", "libswscale": "f7869be7bad25441dea17324abcaedd06d261e7ff60a8b524868b5732126e2ac"]

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
