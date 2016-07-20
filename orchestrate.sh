#!/bin/bash

if [ -z $D_NETWORK ]; then
    export D_NETWORK=ds_net
fi

if [ -z $D_PROJECT]; then
    export D_PROJECT=ds
fi

# Create a new cluster, the first param for this function is the driver.
# We support virtualbox and digitalocean
function d12_cluster_create {
    ./cluster/create.sh ${1}
}

# Destroy all cluster
function d12_cluster_destroy {
    ./cluster/destroy.sh
}

# Create base network
function d12_create_network {
    docker network create -d overlay ${D_NETWORK}
}

# Start mysql
function d12_run_mysql() {
    docker run \
        --net ${D_NETWORK} \
        --name ${D_PROJECT}_mysql \
        -e MYSQL_ROOT_PASSWORD=root -d mysql
}

# Run gianarb/micro the first param is the version.
# You can use 1.0.0, 2.0.0 or latest.
function d12_run_micro() {
    version=$1
    if [ -z $version ]; then
        version=latest
    fi
    if [ "$version" = "1.0.0" ]; then
        docker run -d --name ${D_PROJECT}_micro_$(echo $version | head -c 1) \
            --net ${D_NETWORK} \
            -p 8000:8000 \
            gianarb/micro:${version}
    else
        docker run -d --name ${D_PROJECT}_micro_$(echo $version | head -c 1) \
            --net ${D_NETWORK} \
            -e MYSQL_USERNAME=root \
            -e MYSQL_PASSWORD=root \
            -e MYSQL_ADDR=${D_PROJECT}_mysql \
            -p 8000:8000 \
            gianarb/micro:${version}
    fi
}

# Create a dummy service that ping docker.com
function d12_dummy_service {
    docker service create --name helloworld --replicas 1 alpine ping docker.com
}

# Scale dummy servier up from 1 to 10
function d12_dummy_service_scale_up {
    docker service scale helloworld=10
}

# Start a new service for gianarb/micro
function d12_micro_service() {
    version=$1
    if [ -z $version ]
        then version=latest
    fi
    if [ $version = "1.0.0" ]; then
        echo 'hello'
        docker service create \
            --name ${D_PROJECT}_micro \
            --network ${D_NETWORK} \
            --replicas 10 \
            --publish 8000/tcp gianarb/micro:${version}
    else
        docker service create \
            --name ${D_PROJECT}_micro \
            --network ${D_NETWORK} \
            -e MYSQL_USERNAME=root \
            -e MYSQL_PASSWORD=root \
            -e MYSQL_ADDR=${D_PROJECT}_mysql \
            --replicas 10 \
            --publish 8000/tcp gianarb/micro:${version}
    fi
}

# Update ds_service 1.0.0 to 2.0.0
function d12_micro_service_update_to_200 {
    docker service update \
        --update-delay 10m \
        --update-parallelism 2 \
        --image gianarb/micro:2.0.0 ${D_PROJECT}_micro
}
