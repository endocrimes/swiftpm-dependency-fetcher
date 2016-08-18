
build:
	docker build .

run-local:
	docker run -it --rm -v $PWD:/package -p 8080:8080 6e0153663fa4

run-server:
	docker run -it -d --restart=on-failure -v $PWD:/package -p 80:8080 114b974c221e

