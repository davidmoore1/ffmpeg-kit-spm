// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "v5.1.5"

let frameworks = ["ffmpegkit": "eaa8f405f6af11d6f9a448f4d17f9e2d5c40e3a64c0462be58f7dc4aed684345", "libavcodec": "c07fe1f98df50c2aa930f0b83c20eea3773836262650ea66710ecb3db2abcf2b", "libavdevice": "61269ba59ee30caf6537828e64a66c6eef1575e8d6c5707e6c4edc6c8ef06ac8", "libavfilter": "969561cb02020b3bd5b982149e2971cc64b64d5535ab548a3a3d655702dfdac1", "libavformat": "4c2c8be7532c4a85a6615559e6a33bbdd3270b03ddc86d6c825c15d53b7495d5", "libavutil": "131db1786b8c277869968fc48528590f78beb67fa3f2866e681afa9291531564", "libswresample": "ad45d66372dba4569da4b50e2435631a061c3dff8723187c7ed51efe9a90b1a1", "libswscale": "1d4524af2b0472a7ab375f6d1efdd4e93c91ca2e32fc0027c2096fa955dabe3b"]

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
