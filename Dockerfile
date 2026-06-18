ARG GO_VERSION=1.25.8
ARG GO_IMAGE_DIGEST=sha256:7af46e70d2017aef0b4ce2422afbcf39af0511a61993103e948b61011233ec42
FROM golang:${GO_VERSION}-bookworm@${GO_IMAGE_DIGEST} AS go-dist

FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

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
