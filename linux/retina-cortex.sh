#!/bin/bash

start_services() {
    echo "Starting services..."

    # Check if the 'exalens' network exists
    if ! docker network ls | grep -q "exalens"; then
        echo "'exalens' network does not exist. Creating network..."
        docker network create exalens
    else
        echo "'exalens' network already exists."
    fi

    # Start the containers
    docker run -d --name cortexCtrl --network exalens -v ~/.exalens:/opt -v /var/run/docker.sock:/var/run/docker.sock exalens/community_cortex_ctrl:latest
    echo "Services started."
}

stop_services() {
    echo "Stopping services..."
    docker stop cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB
    echo "Services stopped."
}

case "$1" in
    --start)
        start_services
        ;;
    --stop)
        stop_services
        ;;
    *)
        echo "Usage: $0 --start | --stop"
        exit 1
esac
