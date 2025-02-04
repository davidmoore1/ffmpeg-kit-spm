// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.3.5"

let frameworks = ["ffmpegkit": "e0f5f21f9dddd820a8c7370cddb91d82d0b45dfcdb058999eb5133b67cc6e621", "libavcodec": "1c53220e130b0ddc08fc0f8273e30c91775ccebf1282702136cc122df048cb16", "libavdevice": "d8015cbbf7bb5d36e4e480b4ba4f64eaf575d3f950cebd954eb749e679f84332", "libavfilter": "2e7bb906bb9cddd79b1915f5c02b00b43d99929fe99098efaea6b6aab0739815", "libavformat": "259d405b4636c8b7def062c14a1977660869db8fb5feee07fde60232e3cb2af0", "libavutil": "ef3ef384906ae82de6158c06e49b8ab6f00a18a573954595908c9a0d2ce55717", "libswresample": "d143d62e05c077016d0bac84370c4b688db099826fefc5fd54c5a2280fa1e09d", "libswscale": "c11823de4a1ec88be01f9119b445c683941e64b55a35d4459f4f61ab9f778090"]

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
