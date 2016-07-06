#!/bin/bash

token=$(docker run --rm swarm create)

# Swarm manager machine
echo "Create swarm manager"
docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --swarm --swarm-master \
    --engine-install-url https://test.docker.com \
    --engine-opt="cluster-advertise=eth0:2376" \
    manager

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --engine-install-url https://test.docker.com \
    --swarm \
    --engine-opt="cluster-advertise=eth0:2376" \
    jenkins-master &

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --engine-install-url https://test.docker.com \
    --swarm \
    --engine-opt="cluster-advertise=eth0:2376" \
    jenkins1 &

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --engine-install-url https://test.docker.com \
    --swarm \
    --engine-opt="cluster-advertise=eth0:2376" \
    jenkins2 &
wait

# Information
echo ""
echo "CLUSTER INFORMATION"
echo "discovery token: ${token}"
echo "Environment variables to connect trough docker cli"
docker-machine env --swarm manager
