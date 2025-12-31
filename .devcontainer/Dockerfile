FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Copy scripts into the container image
COPY scripts /tmp/devcontainer-scripts
RUN chmod +x /tmp/devcontainer-scripts/*.sh

# Set up the vscode user
USER vscode
