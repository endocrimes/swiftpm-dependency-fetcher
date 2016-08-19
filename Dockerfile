
FROM kylef/swiftenv
RUN swiftenv install DEVELOPMENT-SNAPSHOT-2016-07-25-a

# install redis
RUN cd /tmp && curl -O http://download.redis.io/redis-stable.tar.gz && tar xzvf redis-stable.tar.gz >/dev/null 2>&1 && cd redis-stable && make >/dev/null 2>&1 && make install
RUN apt-get install -y libssl-dev

WORKDIR /package
VOLUME /package
EXPOSE 8080

# mount in local sources via:  -v $(PWD):/package

CMD redis-server ./Redis/redis.conf && swift build && .build/debug/swiftpm-dependency-fetcher
