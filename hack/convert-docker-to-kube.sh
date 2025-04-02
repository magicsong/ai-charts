#!/usr/bin/env bash

set -e

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed. Please install Go first."
    exit 1
fi

# Install kompose
echo "Installing kompose using Go..."
go install github.com/kubernetes/kompose@latest

# Add Go bin directory to PATH if needed
if ! command -v kompose &> /dev/null; then
    echo "Adding Go bin directory to PATH"
    export PATH=$PATH:$(go env GOPATH)/bin
fi

# Verify kompose is installed
if ! command -v kompose &> /dev/null; then
    echo "Error: Failed to install kompose. Please check your Go installation."
    exit 1
fi

echo "Kompose successfully installed!"

# Process Docker Compose files
if [ $# -eq 0 ]; then
    echo "Usage: $0 [docker-compose-file] [output-dir]"
    echo "If no file is specified, docker-compose.yml in the current directory will be used."
    docker_compose="docker-compose.yml"
    output_dir="kubernetes"
else
    docker_compose="$1"
    output_dir="${2:-kubernetes}"
fi

# Check if Docker Compose file exists
if [ ! -f "$docker_compose" ]; then
    echo "Error: Docker Compose file '$docker_compose' not found"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Convert Docker Compose to Kubernetes resources
echo "Converting Docker Compose file to Kubernetes resources..."
kompose convert -f "$docker_compose" -o "$output_dir"

echo "Conversion complete! Kubernetes resources are available in '$output_dir' directory."