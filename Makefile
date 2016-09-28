
build:
	swift build

run:
	.build/debug/swiftpm-dependency-fetcher

run-local:
	docker run -it --rm -v $PWD:/package -p 8080:8080 -e "GITHUB_TOKEN=$GITHUB_TOKEN" 28334ebecb3e

run-server:
	docker run -it -d --restart=on-failure -v $PWD:/package -p 80:8080 -e "GITHUB_TOKEN=$GITHUB_TOKEN" 114b974c221e

