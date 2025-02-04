// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.3.4"

let frameworks = ["ffmpegkit": "6368eca002c089eeb47a280acc2e49d9dfaeba0fcec738c52956bbffa1932aa1", "libavcodec": "070fb40af32c65f06598268175b0b10c798eb6181474ef72f136b84b06f516fc", "libavdevice": "6e5a29b9a58b2a2c695fbdeda3093263ef7f225cd7f9c6fd444d6d1d0864f6be", "libavfilter": "cfb7a9f2d3a305a4d744907580eff1668e4aa805f6a82069f3e6d8757a1ed0cd", "libavformat": "ba18e58f96d471d8bddbd562675b0e3eeb0c958a004c776f35a7180ad55d19dd", "libavutil": "ea4552ecd3c22361541664974a8c7855561b532a67061d54d5fb8f05a237cfb0", "libswresample": "bfba2da9109a33d9536c1c1aabd038ca300c4426dac710297faa602f0c834677", "libswscale": "f5c07376373c9995f2c7cc72726dd895f1a9fbccc22079af437b47bfc36f7e3e"]

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
