FROM kylef/swiftenv

RUN swiftenv install DEVELOPMENT-SNAPSHOT-2016-08-18-a

# install libssl and graphviz
RUN apt-get update && apt-get install -y libssl-dev graphviz

EXPOSE 8080

WORKDIR /app
VOLUME /app

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["run"]
