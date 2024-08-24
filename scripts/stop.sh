#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Stopping all IOH Microservices...${NC}"

stop_services() {
    local compose_file="$1"
    local stack_name="$2"
    echo -e "${YELLOW}Stopping $stack_name services...${NC}"
    if docker compose -f "$compose_file" ps --services | grep -q .; then
        docker compose -f "$compose_file" stop
        echo -e "${GREEN}$stack_name services stopped successfully.${NC}"
    else
        echo -e "${YELLOW}No running services found for $stack_name.${NC}"
    fi
}

stop_services "docker-compose.yml" "Main"

stop_services "docker-compose.grafana.yml" "Grafana"

stop_services "docker-compose.local.yml" "Local"

echo -e "${GREEN}All IOH Microservices have been stopped.${NC}"
echo -e "${GREEN}Containers and data are preserved.${NC}"
echo -e "${GREEN}To start the services again, use 'sh scripts/start.sh'${NC}"