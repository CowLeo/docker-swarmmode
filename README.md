This repo contains some utilities to approach the new built-in orchestration service provided by Docker 1.12.

To understand how deploy and update an application I integrated like submodule [micro](https://github.com/gianarb/micro) a 12factor application writte in go. It provides two endpoint, the most important is the index `/` that print the current IP. Read more into the readme of the micro's repository.

All the content of this project is in `bash` and the entrypoint is `./orchestration.sh` you can start with this command directly from your terminal
```bash
source ./orchestration.sh
```
Just to load all functions provided.

## Cluster

Therea are two utilities to create and destroy a cluster of Docker 1.12 in swarm mode.
Creation supports two drivers digitalocean and virtualbox and use `docker-machine`.
```bash
d12_custer_create virtualbox/digitalocean
```
If you are trying to use digitalocean there is an environment variable called `$DO` to export, it contains the digitalocean's tocken. If you are usigin virtualbox you are ready to go.

To destroy your cluster you can use 
```bash
d12_cluster_destroy
```
Now that you have a cluster you can show nodes and how join a new server in your cluster.

## Network
This projects contains a high level point of view of how swarm works and to make all really easy we use just one overlay network called `ds_net` but you can export an environment variable to override the name `export D_NETWORK=your_network_name`
```bash
d12_create_network
```

## Dummy Service
The first service that you can deploy is a simple ping to `docker.com` and there is also a function to scale up it to 10 tasks.
```bash
# docker service create --name helloworld --replicas 1 alpine ping docker.com
d12_dummy_service

# Scale dummy servier up from 1 to 10
#  docker service scale helloworld=10
function d12_dummy_service_scale_up
```
At this point you can show few stuff like what is a service, tasks, inspect them and try to tail logs from a specific container (remember that you has visibility only container into the manager (if your client point that server).

## Micro 1.0
There are two version of micro, we can start to deploy v1.
```
d12_micro_service
```
It doesn't require any other apps after this function you have a service called `ds_micro` and 10 tasks. You can inspect it in order to catch the entrypoint and see the index `docker service inspect ds_micro`.

## Road to micro 2.0
Right now you are ready to start an update of your service to version 2.0.0.
```bash
#  docker service update --update-delay 10m --update-parallelism 2 --image gianarb/micro:2.0.0 ${D_PROJECT}_micro
d12_micro_service_update_to_200
```
Follow the update and you can explain something around canary release and healthcheck (right now 20/july not supported yet)
