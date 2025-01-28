// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.3"

let frameworks = ["ffmpegkit": "cb29a9a24b4ecacf5a70fe19f50245d843fd08b6bbab8c1dc7184ba506d38275", "libavcodec": "4b9300f85ab3d3d876dceac236a964c54bf7ab94946dc436bdf2c82e844fcd3c", "libavdevice": "29d28e83cdcf63c539d18daea45601cdff4d9867056d5153e1d6fc19d2ffdbcb", "libavfilter": "891bc86163d860be96cd12c004d3123f3080e95947d7cc0c186fc81932479ed0", "libavformat": "f2bef3f5d7e1c1cbecbb67f1c798abbbadcbbd3e4925df8c411d0a7453a1ef12", "libavutil": "445fc90a94ec1d031fa652bf41178207db56c1c7b077062ae19bdc74f3a59d64", "libswresample": "a5c5b11fbed1788f395601c307e3f7b3ac9bcc762988c5b9343a0a2beba90295", "libswscale": "f6d412f010715c0cac338e89ccb67d55c51d3dbc299225a97824ab8253384e32"]

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
