FROM adoptopenjdk:11-jre-openj9

RUN groupadd -r dynamodblocal && useradd -r -m -g dynamodblocal dynamodblocal

RUN set -ex; \
    \
    SU_EXEC_VERSION=212b75144bbc06722fbd7661f651390dc47a43d1; \
    \
    buildDeps='gcc libc6-dev make'; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        wget \
        $buildDeps \
    ; \
    \
    wget -O su-exec.tar.gz "https://github.com/ncopa/su-exec/archive/$SU_EXEC_VERSION.tar.gz"; \
    tar -xf su-exec.tar.gz; \
    rm su-exec.tar.gz; \
    \
    make -C "su-exec-$SU_EXEC_VERSION"; \
    mv "su-exec-$SU_EXEC_VERSION/su-exec" /usr/local/bin; \
    rm -r "su-exec-$SU_EXEC_VERSION"; \
    \
    apt-get purge -y --auto-remove $buildDeps; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /home/dynamodblocal

RUN set -ex; \
    \
    wget https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz; \
    su-exec dynamodblocal:dynamodblocal tar -xf dynamodb_local_latest.tar.gz; \
    rm dynamodb_local_latest.tar.gz

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["java", "-jar", "DynamoDBLocal.jar", "-dbPath", "/var/data/dynamodb-local"]
