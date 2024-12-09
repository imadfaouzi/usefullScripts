#!/bin/bash

# Make sure we're in the correct directory
echo "Starting deployment in folder: $PWD"

# Pull the latest images
echo "Pulling latest Docker images..."
docker-compose -f docker-compose-preprod.yml pull

# Bring up the containers (detached mode)
echo "Starting containers..."
docker-compose  -f docker-compose-preprod.yml up -d

# Optionally, clean up old images (optional)
# docker image prune -f

echo "Deployment complete."
