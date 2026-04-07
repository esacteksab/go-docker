ARG GO_VERSION=1.25.8
ARG GO_IMAGE_DIGEST=sha256:7af46e70d2017aef0b4ce2422afbcf39af0511a61993103e948b61011233ec42
FROM golang:${GO_VERSION}-bookworm@${GO_IMAGE_DIGEST} AS go-dist

FROM ubuntu:24.04@sha256:84e77dee7d1bc93fb029a45e3c6cb9d8aa4831ccfcc7103d36e876938d28895b

ARG GO_VERSION
LABEL org.opencontainers.image.version="${GO_VERSION}"

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
ENV GO_VERSION=${GO_VERSION}

COPY --from=go-dist /usr/local/go /usr/local/go

RUN mkdir -p /go/src /go/bin && chmod -R 750 /go

# Set the working directory
WORKDIR /go
