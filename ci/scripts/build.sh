#!/bin/bash -eux

pushd dp-jaeger-tracing
  cp Dockerfile.concourse ../build
popd
