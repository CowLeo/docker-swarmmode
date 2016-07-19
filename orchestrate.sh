#!/bin/bash

if [ -z $D_NETWORK ]; then
    export D_NETWORK=ds_net
fi

if [ -z $D_PROJECT]; then
    export D_PROJECT=ds
fi

function d12_cluster_create {
    ./cluster/create.sh ${1}
}

function d12_cluster_destroy {
    ./cluster/destroy.sh
}

function d12_create_network {
    docker network create -d overlay ${D_NETWORK}
}

function d12_run_registry() {
    docker run -d \
        --name ${D_PROJECT}_registry \
         -p 5000:5000 \
         registry
}

function d12_run_mysql() {
    docker run \
        --net ${D_NETWORK} \
        --name ${D_PROJECT}_mysql \
        -e MYSQL_ROOT_PASSWORD=root -d mysql
}

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

function d12_dummy_service {
    docker service create --name helloworld --replicas 1 alpine ping docker.com
}

function d12_dummy_service_scale_up {
    docker service scale helloworld=10
}

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
