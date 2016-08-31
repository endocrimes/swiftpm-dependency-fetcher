import PackageDescription

let package = Package(
    name: "swiftpm-dependency-fetcher",
    dependencies: [
    	.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 0, minor: 17),
    	.Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/czechboy0/Redbird.git", majorVersion: 0, minor: 10)
    ]
)
