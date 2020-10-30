#!/bin/sh

set -e

mkdir -p /var/data/dynamodb

chown -R dynamodb:dynamodb /var/data/dynamodb

su-exec dynamodb authbind --deep "$@"
