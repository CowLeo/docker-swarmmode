#!/bin/bash

token=$(docker run --rm swarm create)

# Swarm manager machine
echo "Create swarm manager"
docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO \
    --engine-install-url https://test.docker.com \
    sw1
docker-machine ssh sw1 docker swarm init

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO \
    --engine-install-url https://test.docker.com \
    sw2 && docker-machine ssh sw2 docker swarm join $(docker-machine ip sw1):2377 &

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO \
    --engine-install-url https://test.docker.com  \
    sw3 && docker-machine ssh sw3 docker swarm join $(docker-machine ip sw1):2377 &

docker-machine create \
    -d digitalocean \
    --digitalocean-access-token=$DO \
    --engine-install-url https://test.docker.com \
    sw4 && docker-machine ssh sw2 docker swarm join $(docker-machine ip sw1):2377 &
wait

# Information
echo ""
echo "CLUSTER INFORMATION"
echo "discovery token: ${token}"
echo "Environment variables to connect trough docker cli"
docker-machine env sw1
