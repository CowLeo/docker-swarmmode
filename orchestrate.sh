#!/bin/bash

if [$D_NETWORK -eq ""]
    then export D_NETWORK=ds_net
fi

if [$D_PROJECT = ""]
    then export D_PROJECT=ds
fi

function d12_create_network {
    docker network create ${D_NETWORK}
}

function d12_cluster_create {
    exec ./cluster/create.sh
}

function d12_cluster_destroy {
    exec ./cluster/destroy.sh
}


function d12_run_micro() {
    version=$1
    if [ -z $version ]
        then version=latest
    fi
    if [$version -eq 1.0.0]
    then
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
