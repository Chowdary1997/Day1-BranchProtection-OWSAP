# Use official minimal base image
FROM alpine:3.18 as builder

# Install build dependencies
RUN apk add --no-cache \
    curl \
    jq \
    openssl

# Download OWASP dependency-check
RUN curl -sSLo /tmp/dependency-check.zip \
    https://github.com/jeremylong/DependencyCheck/releases/download/v8.3.1/dependency-check-8.3.1-release.zip && \
    unzip /tmp/dependency-check.zip -d /opt && \
    rm /tmp/dependency-check.zip

# Runtime image
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache \
    openjdk17-jre \
    bash

# Copy dependency-check from builder
COPY --from=builder /opt/dependency-check /opt/dependency-check

# Add to PATH
ENV PATH="/opt/dependency-check/bin:${PATH}"

# Create a volume for the database
VOLUME /usr/share/dependency-check/data

# Create a volume for reports
VOLUME /report

# Create working directory
WORKDIR /src

# Entrypoint
ENTRYPOINT ["dependency-check.sh"]
CMD ["--help"]
