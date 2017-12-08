import PackageDescription
let package = Package(
	name: "ZDeploy",
	targets: [],
	dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 3)
	]
)
