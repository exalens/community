#!/bin/bash

# Function to pull an image if not present
pull_if_not_exists() {
    if ! docker image inspect $1 > /dev/null 2>&1; then
        echo "Image $1 not found. Pulling..."
        docker pull $1
    else
        echo "Image $1 already exists."
    fi
}

pull_images() {
    echo "Pulling all images..."

    # Pull all the containers
    docker pull exalens/community_broker:latest
    docker pull exalens/community_cache_db:latest
    docker pull exalens/community_threat_intel_db:latest
    docker pull exalens/community_keycloak_db:latest
    docker pull exalens/community_keycloak:latest
    docker pull exalens/community_restapi:latest
    docker pull exalens/community_webserver:latest
    docker pull exalens/community_cortex:latest
    docker pull exalens/community_cache_mongo_db:latest
    docker pull exalens/community_threat_intel_mongo_db:latest
    docker pull exalens/community_cortex_ctrl:latest
    docker pull exalens/community_probe:latest
    docker pull exalens/community_probe_ctrl:latest
    docker pull exalens/community_zeek:latest
}

start_services() {
    echo "Starting services..."

    # Check if the 'exalens' network exists
    if ! docker network ls | grep -q "exalens"; then
        echo "'exalens' network does not exist. Creating network..."
        docker network create exalens
    else
        echo "'exalens' network already exists."
    fi

    # Pull necessary images if not exists
    pull_if_not_exists exalens/community_broker:latest
    pull_if_not_exists exalens/community_cache_db:latest
    pull_if_not_exists exalens/community_threat_intel_db:latest
    pull_if_not_exists exalens/community_keycloak_db:latest
    pull_if_not_exists exalens/community_keycloak:latest
    pull_if_not_exists exalens/community_restapi:latest
    pull_if_not_exists exalens/community_webserver:latest
    pull_if_not_exists exalens/community_cortex:latest
    pull_if_not_exists exalens/community_cache_mongo_db:latest
    pull_if_not_exists exalens/community_threat_intel_mongo_db:latest
    pull_if_not_exists exalens/community_cortex_ctrl:latest
    pull_if_not_exists exalens/community_probe:latest
    pull_if_not_exists exalens/community_probe_ctrl:latest
    pull_if_not_exists exalens/community_zeek:latest

    docker run -d --name cortexCtrl --network exalens --restart always -v ~/.exalens:/opt -v /var/run/docker.sock:/var/run/docker.sock exalens/community_cortex_ctrl:latest
    echo "Services started."
}

stop_services() {
    echo "Stopping services..."
    docker stop cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB probe probe_ctrl zeek
    docker rm cortexCtrl broker cacheDB threatIntelDB keycloakDB keycloak restApi webserver cortex cacheMongoDB threatIntelMongoDB probe probe_ctrl zeek
    echo "Services stopped."
}

clean_install() {
    echo "Performing a clean install..."

    # Stop all running services
    echo "Stopping all running services..."
    stop_services

    # Delete the .exalens folder
    echo "Deleting .exalens folder..."
    rm -rf ~/.exalens

    # Pull all Docker images
    echo "Pulling latest Docker images..."
    pull_images

    # Restart the services
    echo "Restarting services..."
    start_services

    echo "Clean install completed."
}

update_images() {
    echo "Updating all images..."

    # Stop all running services
    echo "Stopping all running services..."
    stop_services

    # Pull all Docker images
    echo "Pulling latest Docker images..."
    pull_images

    # Restart the services
    echo "Restarting services..."
    start_services

    echo "Update completed."
}

case "$1" in
    --start)
        start_services
        ;;
    --stop)
        stop_services
        ;;
    --clean-install)
        clean_install
        ;;
    --update)
        update_images
        ;;
    *)
        echo "Usage: $0 --start | --stop | --clean-install | --update"
        exit 1
esac
