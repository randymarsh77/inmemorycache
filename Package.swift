// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "InMemoryCache",
	products: [
		.library(
			name: "InMemoryCache",
			targets: ["InMemoryCache"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/randymarsh77/pubsubcache", .branch("master")),
	],
	targets: [
		.target(
			name: "InMemoryCache",
			dependencies: ["PubSubCache"]
		),
	]
)
