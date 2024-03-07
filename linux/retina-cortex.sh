#!/bin/bash

TAG="latest"

# Function to pull an image if not present
pull_if_not_exists() {
    if ! docker image inspect $1 > /dev/null 2>&1; then
        echo "Image $1 not found. Pulling..."
        docker pull $1
    fi
}

set_tag() {
  TAG=$1
  if [ -z "$TAG" ]; then
#    echo "Please provide the tag for images."
#    read TAG
    TAG="latest"
  fi

}


pull_images() {

    echo "Pulling all images with tag :$TAG..."

    # Pull all the containers
    docker pull exalens/community_broker:$TAG
    docker pull exalens/community_cache_db:$TAG
    docker pull exalens/community_threat_intel_db:$TAG
    docker pull exalens/community_keycloak_db:$TAG
    docker pull exalens/community_keycloak:$TAG
    docker pull exalens/community_webserver:$TAG
    docker pull exalens/community_cortex:$TAG
    docker pull exalens/community_cache_mongo_db:$TAG
    docker pull exalens/community_threat_intel_mongo_db:$TAG
    docker pull exalens/community_zeek:$TAG
}

start_services() {
    echo "Starting services...(TAG :$TAG)"
    clear_progress_file

    # Function to stop and remove a container if it is running
    stop_and_remove_if_running() {
        if docker ps --format '{{.Names}}' | grep -q $1; then
            echo  -n "."
            docker stop $1 > /dev/null
            echo  -n "."
            docker rm $1 > /dev/null
        fi
    }

    # Check and stop/remove containers if they are already running
    stop_and_remove_if_running cortexCtrl
    stop_and_remove_if_running broker
    stop_and_remove_if_running cacheDB
    stop_and_remove_if_running threatIntelDB
    stop_and_remove_if_running keycloakDB
    stop_and_remove_if_running keycloak
    stop_and_remove_if_running restApi
    stop_and_remove_if_running webserver
    stop_and_remove_if_running cortex
    stop_and_remove_if_running cacheMongoDB
    stop_and_remove_if_running threatIntelMongoDB
    stop_and_remove_if_running probe
    stop_and_remove_if_running probe_ctrl
    stop_and_remove_if_running zeek

    # Check if the 'exalens' network exists
    if ! docker network ls | grep -q "exalens"; then
        docker network create exalens
    fi

    # Pull necessary images if not exists
    pull_if_not_exists exalens/community_broker:$TAG
    pull_if_not_exists exalens/community_cache_db:$TAG
    pull_if_not_exists exalens/community_threat_intel_db:$TAG
    pull_if_not_exists exalens/community_keycloak_db:$TAG
    pull_if_not_exists exalens/community_keycloak:$TAG
    pull_if_not_exists exalens/community_webserver:$TAG
    pull_if_not_exists exalens/community_cortex:$TAG
    pull_if_not_exists exalens/community_cache_mongo_db:$TAG
    pull_if_not_exists exalens/community_threat_intel_mongo_db:$TAG
    pull_if_not_exists exalens/community_zeek:$TAG

    # Start the containers
    docker run -d --name cortexCtrl --network exalens --restart always -v ~/.exalens:/opt -v /var/run/docker.sock:/var/run/docker.sock exalens/community_cortex:$TAG > /dev/null


    progress
    echo "Services started."
}


stop_services() {
    echo "Stopping and removing services..."

    # Function to stop and remove a container only if it is running
    stop_and_remove_if_running() {
        if docker ps --format '{{.Names}}' | grep -q $1; then
            echo  -n "."
            docker stop $1 > /dev/null
            echo  -n "."
            docker rm $1 > /dev/null
        fi
    }

    # Stop and remove each container only if it is running
    stop_and_remove_if_running cortexCtrl
    stop_and_remove_if_running broker
    stop_and_remove_if_running cacheDB
    stop_and_remove_if_running threatIntelDB
    stop_and_remove_if_running keycloakDB
    stop_and_remove_if_running keycloak
    stop_and_remove_if_running restApi
    stop_and_remove_if_running webserver
    stop_and_remove_if_running cortex
    stop_and_remove_if_running cacheMongoDB
    stop_and_remove_if_running threatIntelMongoDB
    stop_and_remove_if_running probe
    stop_and_remove_if_running probe_ctrl
    stop_and_remove_if_running zeek

    echo "stop completed."
}


clean_install() {
    echo "Performing a clean install..."

    # Stop all running services
    echo "Stopping all running services..."
    stop_services

    # Delete the .exalens folder
    echo "Deleting .exalens folder..."
    sudo rm -rf ~/.exalens

    # Pull all Docker images
    echo "Pulling Docker images with tag $TAG..."
    pull_images

    # Restart the services
    echo "Restarting services..."
    start_services

    echo "Clean install completed."
}

update_images() {
    echo "Updating all images with tag $TAG..."

    # Stop all running services
    echo "Stopping all running services..."
    stop_services

    # Pull all Docker images
    echo "Pulling Docker images with tag $TAG..."
    pull_images

    # Restart the services
    echo "Restarting services..."
    start_services

    echo "Update completed."
}


file_path="$HOME/.exalens/retinaCortex/log/boot.log"
clear_progress_file(){
  # Delete the file if it exists
  if [ -f "$file_path" ]; then
      rm -f "$file_path"
  fi

}

progress(){

  extract_percentage() {
      echo "$1" | grep -oP '(?<=:)\d+(?=%)'
  }

  prev_percent="0"

  while [ ! -f "$file_path" ]; do
      echo -ne "\r${spinner:$i:1} Current progress: $prev_percent% \r"
      sleep 0.1
  done



  tail -f "$file_path" | while read line; do
      percent=$(extract_percentage "$line")
      if [ ! -z "$percent" ] && [ "$percent" != "$prev_percent" ]; then
          echo -ne "Current progress: $percent% \r"
          prev_percent=$percent
      fi

      if [[ "$percent" =~ ^[0-9]+$ ]] && [ "$percent" -eq 100 ]; then
          echo -ne "\nStartup completed.\n"
          break
      fi
  done

}

stop_and_remove_if_running() {
    if docker ps --format '{{.Names}}' | grep -q $1; then
        docker stop $1 > /dev/null
        docker rm $1 > /dev/null
    fi
}

update_probe_hostname(){
  docker exec probe_ctrl python3.10 updateHostname.py $1
}

case "$1" in
    --start)
        set_tag $2
        start_services
        ;;
    --stop)
        stop_services
        ;;
    --clean-install)
        set_tag $2
        clean_install
        ;;
    --update)
        set_tag $2
        update_images
        ;;
    --update-hostname)
        update_probe_hostname "$2"
        ;;
    *)
        echo "Usage: $0 --start {tag}| --stop | --clean-install {tag} | --update {tag} | --update-hostname {hostname}"
        exit 1
esac
