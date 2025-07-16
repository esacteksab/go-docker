FROM ubuntu:24.04@sha256:c4570d2f4665d5d118ae29fb494dee4f8db8fcfaee0e37a2e19b827f399070d3

ARG GO_VERSION=1.24.5

# Install dependencies, download Go, and set it up in one layer
RUN set -eux && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        wget && \
    wget -O go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    rm /root/.wget-hsts && \
    mkdir -p /go/src /go/bin && \
    chmod -R 777 /go && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/apt/* && \
    rm -rf /var/log/dpkg.log

# Set environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH
ENV CGO_ENABLED=0

# Set the working directory
WORKDIR /go
