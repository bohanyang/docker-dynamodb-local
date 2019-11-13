#!/usr/bin/env sh

set -e

mkdir -p /var/data/dynamodb-local

chown -R dynamodblocal:dynamodblocal /var/data/dynamodb-local

su-exec dynamodblocal:dynamodblocal "$@"
