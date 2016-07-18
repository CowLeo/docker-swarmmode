#!/bin/bash

if $D_NETWORK = "" then
    export D12_NETWORK="demo_today"
endif

function d12_create_network {
    docker network create ${D_NETWORK}
}

function d12_create {
    exec ./cluster/create.sh
}

function d12_destroy {
    exec ./cluster/destroy.sh
}

function d12_start_micro100 {
    docker run -d --name micro \
        --name ${D_NETWORK} \
        -e MYSQL_USERNAME=root \
        -e MYSQL_PASSWORD=root \
        -e MYSQL_ADDR=mysql \
        -p 8000:8000 \
        gianarb/micro:1.0.0
}

function d12_start_micro200 {
    docker run -d --name micro2 \
        --name ${D_NETWORK} \
        -e MYSQL_USERNAME=root \
        -e MYSQL_PASSWORD=root \
        -e MYSQL_ADDR=mysql \
        -p 8000:8000 \
        gianarb/micro:2.0.0
}

function d12_start_mysql {
    docker run -d \
        --name ${D_NETWORK} \
        --net test \
        -e MYSQL_ROOT_PASSWORD=root \
        mysql
}
