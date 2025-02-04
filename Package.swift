// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.4"

let frameworks = ["ffmpegkit": "993109202d643ae93513f1aae0e6d921e2b0148050c651806e476ea312a26125", "libavcodec": "3e6a593527acf40b3714d7c30420d832cf7065fe1ba646bbe505ddaf488d0db7", "libavdevice": "defb7f8c37085d7cce94bf8a5804071a054540d025d576c1b22b16bc45e44c1d", "libavfilter": "9e5b8779346dc3a658f95678e457c73888720310cba9983bc6ab90f30f63c230", "libavformat": "8a0330796a569e236e5fdacc6f9a3761c952d4827e12ed98ca2957239de96638", "libavutil": "3410878ab427c7af8464de3f18a178afee2d9593af294e531d71c93c156d8c63", "libswresample": "581b1b3521008b5dd21047d7814b386e16bfcd17439556ebec832ef90ca99b06", "libswscale": "3d33fdd8b10072f4bda5a41668485c3b34e9e83001e603e0202901e3777f8359"]

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
