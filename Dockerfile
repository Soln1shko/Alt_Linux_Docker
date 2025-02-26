FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /qemu/iso /qemu/hdd

# Create work directory
WORKDIR /qemu

# Copy scripts
COPY scripts/start.sh /qemu/
RUN chmod +x /qemu/start.sh

# Expose VNC port
EXPOSE 5900

# Set entrypoint
ENTRYPOINT ["/qemu/start.sh"]
