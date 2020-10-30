FROM adoptopenjdk:11-jre-openj9

RUN groupadd -r dynamodb \
 && useradd -r -m -g dynamodb dynamodb \
 && groupadd -r web \
 && usermod -a -G web dynamodb

RUN set -ex; \
    \
    SU_EXEC_VERSION=212b75144bbc06722fbd7661f651390dc47a43d1; \
    \
    buildDeps='curl gcc libc6-dev make'; \
    apt-get update; \
    apt-get install -y --no-install-recommends authbind $buildDeps; \
    \
    mkdir -p /etc/authbind/byport; \
    touch /etc/authbind/byport/80; \
    chown root:web /etc/authbind/byport/80; \
    chmod u+x,g+x /etc/authbind/byport/80; \
    \
    curl -fsS "https://github.com/ncopa/su-exec/archive/$SU_EXEC_VERSION.tar.gz" | tar xzf -; \
    make -C "su-exec-$SU_EXEC_VERSION"; \
    mv "su-exec-$SU_EXEC_VERSION/su-exec" /usr/local/bin; \
    rm -r "su-exec-$SU_EXEC_VERSION"; \
    \
    apt-get purge -y --auto-remove $buildDeps; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/dynamodb

RUN su-exec dynamodb:dynamodb sh -c 'curl -fsS https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz | tar xzf -'

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["java", "-jar", "DynamoDBLocal.jar", "-dbPath", "/var/data/dynamodb", "-optimizeDbBeforeStartup", "-port", "80"]
