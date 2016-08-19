import PackageDescription

let package = Package(
    name: "swiftpm-dependency-fetcher",
    dependencies: [
    	.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 0, minor: 16),
        .Package(url: "https://github.com/vapor/vapor-mustache.git", majorVersion: 0, minor: 11),
    	.Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/czechboy0/Redbird.git", majorVersion: 0, minor: 9),
        .Package(url: "https://github.com/czechboy0/Tasks.git", majorVersion: 0, minor: 3)
    ]
)

#if os(Linux)
package.dependencies.append(.Package(url: "https://github.com/vapor/tls-provider.git", "0.0.42"))
#endif
