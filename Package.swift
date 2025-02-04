// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.3.2"

let frameworks = ["ffmpegkit": "66474396d52cc81dc57f015805940b44da5c7c2a10a2b16842b7246c616e664d", "libavcodec": "1887f0ea6894a31052948c7ab0a493d0a5c4728053f3d0714e30a671e5f2f9e8", "libavdevice": "f26ed55ae9a5b9e3a5bebe8102c868db1e20b024a37c5a4a4cd550a1f14d997a", "libavfilter": "dea3c6474ce3e55e6a9420dee57b0fdd35a3211b98151e1b35c38fe3d90d5cb1", "libavformat": "9b56b06fcfcda275cfa17dfd6d7d1f142cfd472f7fd420c57ab6d795ca2cd9e8", "libavutil": "3421f34dbb414cc452c68fa5f1b65418c7dc10ef838dfaa17695df104a305c30", "libswresample": "5cd07f56bdd9466a2a823ad5391d09881dcd3b46ae0684d0f553373dc40bce88", "libswscale": "85519426f08d7cfc495dc70d16df5394475b3ebe874f1e56e07a8d04dd150061"]

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
