#!/bin/bash
if [ -z $1 ]
then
    provider=virtualbox
else
    provider=$1
fi

echo "### Init Servers ###"

if [ "$provider" = "virtualbox" ]; then
    echo "### Virtualbox provider ###"
    docker-machine create -d ${provider} sw1 &
    docker-machine create -d ${provider} sw2 &
    docker-machine create -d ${provider} sw3 &
    docker-machine create -d ${provider} sw4 &
else
    docker-machine create \
        --digitalocean-access-token=$DO \
        --engine-install-url https://test.docker.com \
        -d ${provider} sw1 &
    docker-machine create \
        --digitalocean-access-token=$DO \
        --engine-install-url https://test.docker.com \
        -d ${provider} sw2 &
    docker-machine create \
        --digitalocean-access-token=$DO \
        --engine-install-url https://test.docker.com \
        -d ${provider} sw3 &
    docker-machine create \
        --digitalocean-access-token=$DO \
        --engine-install-url https://test.docker.com \
        -d ${provider} sw4 &
fi

wait

echo "### Configurate cluster ###"

docker-machine ssh sw1 docker swarm init \
    --listen-addr $(docker-machine ip sw1) --auto-accept manager --auto-accept worker --secret toosecret

docker-machine ssh sw2 docker swarm join $(docker-machine ip sw1):2377 --secret toosecret
docker-machine ssh sw3 docker swarm join $(docker-machine ip sw1):2377 --secret toosecret
docker-machine ssh sw4 docker swarm join $(docker-machine ip sw1):2377 --secret toosecret

# Information
echo ""
echo "CLUSTER INFORMATION"
echo "discovery token: ${token}"
echo "Environment variables to connect trough docker cli"
docker-machine env sw1
