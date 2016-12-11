import PackageDescription

let package = Package(
    name: "InMemoryCache",
    dependencies: [
		.Package(url: "https://github.com/randymarsh77/pubsubcache", majorVersion: 0),
	]
)
