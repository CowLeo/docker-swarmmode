#!/bin/bash

token=$(docker run --rm swarm create)

docker-machine create \
    -d digitalocean \
    --engine-install-url https://test.docker.com
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    consul

docker-machine ssh consul docker run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

KV_IP=$(docker-machine ip consul)
KV_ADDR="consul://${KV_IP}:8500"

# Swarm manager machine
echo "Create swarm manager"
docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --swarm --swarm-master \
    --engine-install-url https://test.docker.com \
    --swarm-discovery=$KV_ADDR \
    --engine-opt="cluster-store=${KV_ADDR}" \
    --engine-opt="cluster-advertise=eth0:2376" \
    manager

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --engine-install-url https://test.docker.com \
    --swarm \
    --swarm-discovery=$KV_ADDR \
    --engine-opt="cluster-store=${KV_ADDR}" \
    --engine-opt="cluster-advertise=eth0:2376" \
    jenkins-master &

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --engine-install-url https://test.docker.com \
    --swarm \
    --swarm-discovery=$KV_ADDR \
    --engine-opt="cluster-store=${KV_ADDR}" \
    --engine-opt="cluster-advertise=eth0:2376" \
    jenkins1 &

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO_ACCESS_TOKEN \
    --engine-install-url https://test.docker.com \
    --swarm \
    --swarm-discovery=$KV_ADDR \
    --engine-opt="cluster-store=${KV_ADDR}" \
    --engine-opt="cluster-advertise=eth0:2376" \
    jenkins2 &
wait

# Information
echo ""
echo "CLUSTER INFORMATION"
echo "discovery token: ${token}"
echo "Environment variables to connect trough docker cli"
docker-machine env --swarm manager
