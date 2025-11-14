FROM ubuntu:24.04@sha256:e96e81f410a9f9cae717e6cdd88cc2a499700ff0bb5061876ad24377fcc517d7 AS base

ARG GO_VERSION=1.25.3

# Install dependencies, download Go, and set it up in one layer
RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 \
        wget=1.21.4-1ubuntu4.1 && \
    wget -O go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    rm /root/.wget-hsts && \
    mkdir -p /go/src /go/bin && \
    chmod -R 750 /go && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

# Set the working directory
WORKDIR /go

FROM ubuntu:24.04@sha256:e96e81f410a9f9cae717e6cdd88cc2a499700ff0bb5061876ad24377fcc517d7


RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20240203 && \
    apt-get clean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

COPY --from=base /usr/local/go /usr/local/go

# Set the working directory
WORKDIR /go
