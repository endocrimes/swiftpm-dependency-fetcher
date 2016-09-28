#!/usr/bin/env bash

set -ex

echo $1

wait_for_redis() {
  sleep 30
}

successfully() {
	$* || (echo "failed" 1>&2 && exit 1)
}

build_server() {
  echo "* Building Swift Package"
  successfully make build
  echo "* Built swift package"
}

run_server() {
  echo "* Running swiftpm-dependency-fetcher"
  successfully make run
}

if [[ "$1" == "run" ]]
then
  successfully wait_for_redis
  run_server
fi
