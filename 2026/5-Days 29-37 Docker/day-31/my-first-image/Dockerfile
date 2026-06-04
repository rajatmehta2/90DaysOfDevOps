# Use official Ubuntu as base image
FROM ubuntu:latest

# Avoid prompt warnings during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package manager and install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set default command
CMD ["echo", "Hello from my custom image!"]
