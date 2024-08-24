#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

start_service() {
    service_name="$1"
    compose_file="$2"
    skip_health_check="$3"

    echo -e "${YELLOW}Starting $service_name...${NC}"
    docker compose -f "$compose_file" up -d "$service_name"

    if [ "$skip_health_check" != "true" ]; then
        echo -e "${YELLOW}Waiting for $service_name to be healthy...${NC}"
        
        max_retries=30
        retries=0
        while [ $retries -lt $max_retries ]
        do
            health_status=$(docker inspect --format='{{.State.Health.Status}}' $(docker compose -f "$compose_file" ps -q "$service_name"))
            
            if [ "$health_status" == "healthy" ]; then
                echo -e "\n${GREEN}$service_name is healthy!${NC}"
                return 0
            elif [ "$health_status" == "unhealthy" ]; then
                echo -e "\n${RED}$service_name is unhealthy. Printing last 50 lines of logs...${NC}"
                docker logs --tail 50 $(docker compose -f "$compose_file" ps -q "$service_name")
                return 1
            fi
            
            printf "${BLUE}Waiting for $service_name to be ready... (%d/%d)${NC}" $((retries+1)) $max_retries
            spinner $$ &
            spinner_pid=$!
            sleep 5
            kill $spinner_pid 2>/dev/null
            wait $spinner_pid 2>/dev/null
            printf "\r\033[K"
            retries=$((retries+1))
        done
        
        echo -e "\n${RED}$service_name did not become healthy within the allocated time.${NC}"
        return 1
    else
        echo -e "${GREEN}$service_name started. Skipping health check.${NC}"
    fi
}

docker network create backend 2>/dev/null || true

# start_service "postgres" "docker-compose.local.yml"
start_service "rabbitmq" "docker-compose.local.yml"
start_service "redis" "docker-compose.local.yml"
start_service "mongodb" "docker-compose.local.yml"

start_service "loki" "docker-compose.grafana.yml"
start_service "fluent-bit" "docker-compose.grafana.yml" true
start_service "grafana" "docker-compose.grafana.yml"
start_service "renderer" "docker-compose.grafana.yml" true

start_service "ioh-auth" "docker-compose.yml" true
start_service "ioh-stories" "docker-compose.yml" true

start_service "kong" "docker-compose.yml"

echo -e "${GREEN}All services have been started successfully!${NC}"