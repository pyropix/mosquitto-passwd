# Pin Alpine version for reproducible builds
FROM alpine:3.19

# Use OCI standard annotations
LABEL org.opencontainers.image.title="mosquitto-passwd"
LABEL org.opencontainers.image.description="OpenSSL and Mosquitto password generator based on Alpine Linux."
LABEL org.opencontainers.image.authors="m.r.hartmann@protonmail.com"
LABEL org.opencontainers.image.vendor="Martin Hartmann"
LABEL org.opencontainers.image.url="https://www.sourcedome.de"
LABEL org.opencontainers.image.source="https://github.com/burkhardm/mosquitto-passwd"
LABEL org.opencontainers.image.documentation="https://github.com/burkhardm/mosquitto-passwd/blob/main/README.md"
LABEL org.opencontainers.image.licenses="MIT"

# Build arguments for metadata
ARG BUILD_DATE=""
ARG VCS_REF=""
ARG BUILD_VERSION="0.2"

# Set metadata using build arguments
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"

# Install dependencies
RUN apk add --no-cache \
    bash \
    mosquitto \
    openssl \
    && rm -rf /var/cache/apk/*

# Create non-root user for running the application
RUN addgroup -g 1000 mosquitto-passwd && \
    adduser -D -u 1000 -G mosquitto-passwd mosquitto-passwd

# Copy script and set permissions
COPY --chown=mosquitto-passwd:mosquitto-passwd ./passwd.sh /passwd.sh
RUN chmod +x /passwd.sh

# Set up volume with appropriate ownership
VOLUME /passwd

# Switch to non-root user
USER mosquitto-passwd

ENTRYPOINT ["/passwd.sh"]
CMD []
