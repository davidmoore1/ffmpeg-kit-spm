// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.4"

let frameworks = ["ffmpegkit": "ff5bf4f2f250198a5d2ef156c685607fa1f5c288dfa7f56d31cbb42bda892dad", "libavcodec": "c9a5443099b16cb57d149f4bafc8af7a6a0868ff94a478cf19ff43abdf54ad46", "libavdevice": "8bad41a871dc467d02016c61e024d362a9b6e144a2867783248b44fe75faa7ac", "libavfilter": "b2ee7826e42044d9a4d57751a087fe4209ac28e446478bef0bc1d5af43e27032", "libavformat": "fbe4d1290667caa20529484ce2c8f2286a24efe07ab3872061892d1746055d74", "libavutil": "9b45fe7a6621de855b33f795040d48f75de1f07587f54eebe18db7cb0047c1ed", "libswresample": "911b095f0d8d24e303031ca9f66afb316ea49d225e3105edb755c2665382fa8c", "libswscale": "3fca8d062c1f7998893a388ca3072e64c64784f637a95521d21df7fc54a99765"]

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
