# Go Development Container

A lightweight Docker container for Go development based on Ubuntu 24.04.

```bash
esacteksab/go                <none>                       3d6df1c54b86   3 hours ago      335MB
golang                       1.24.3-bookworm              f254902cf370   2 days ago       853MB
```

## Overview

This repository contains a Dockerfile and GitHub Actions workflow that creates an image and publishes to Docker Hub weekly.

## Container Details

- **Base Image:** Ubuntu 24.04
- **Go Version:** Configurable via repository variables `GO_VERSION=1.25.0`
- **Registry:** [Docker Hub - esacteksab/go](https://hub.docker.com/r/esacteksab/go)
- **Build Schedule:** Every Friday at 9:00 AM Central Time (US/Chicago)

## Available Tags

- `latest` - The most recent build
- `1.25.0` (or current Go version) - Tagged with the specific Go version
- `1.25.0-YYYY-MM-DD` - Version with build date for historical reference

## Features

- Optimized for static Go binary builds (`CGO_ENABLED=0`)
- Multi-layered image optimization for smaller size
- Configurable Go version via build arguments

## License

MIT
