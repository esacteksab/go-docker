#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker > /dev/null 2>&1; then
	echo "error: docker is required" >&2
	exit 1
fi

if ! command -v curl > /dev/null 2>&1; then
	echo "error: curl is required" >&2
	exit 1
fi

if ! command -v jq > /dev/null 2>&1; then
	echo "error: jq is required" >&2
	exit 1
fi

IMAGE_REPO="${IMAGE_REPO:-esacteksab/go}"
GO_VERSION="${GO_VERSION:-}"
PUSH="${PUSH:-false}"
DATE="$(date +'%Y-%m-%d')"

declare -a VERSIONS=()

if [[ -n "$GO_VERSION" ]]; then
	VERSIONS=("$GO_VERSION")
else
	mapfile -t VERSIONS < <(
		curl -fsSL 'https://go.dev/dl/?mode=json' \
			| jq -r '
				[.[] | select(.stable) | .version]
				| group_by(split(".")[0:2] | join("."))
				| map(max_by(ltrimstr("go") | split(".") | map(tonumber)))[]
				| ltrimstr("go")
			'
	)
fi

if [[ "${#VERSIONS[@]}" -eq 0 ]]; then
	echo "error: no Go versions resolved" >&2
	exit 1
fi

LATEST_VERSION="${VERSIONS[${#VERSIONS[@]}-1]}"

for version in "${VERSIONS[@]}"; do
	stable_line="$(echo "$version" | cut -d. -f1,2)"
	go_image_digest="$(docker buildx imagetools inspect "golang:${version}-bookworm" | awk '/^Digest:[[:space:]]/ {print $2; exit}')"
	if [[ -z "$go_image_digest" ]]; then
		echo "error: failed to resolve digest for golang:${version}-bookworm" >&2
		exit 1
	fi

	tags=(
		"${IMAGE_REPO}:${version}"
		"${IMAGE_REPO}:${stable_line}"
		"${IMAGE_REPO}:${version}-${DATE}"
	)

	if [[ "$version" == "$LATEST_VERSION" ]]; then
		tags+=("${IMAGE_REPO}:latest")
	fi

	echo "Building image with GO_VERSION=${version} GO_IMAGE_DIGEST=${go_image_digest}"
	docker build \
		--build-arg "GO_VERSION=${version}" \
		--build-arg "GO_IMAGE_DIGEST=${go_image_digest}" \
		-t "${tags[0]}" \
		.

	for tag in "${tags[@]:1}"; do
		docker tag "${tags[0]}" "$tag"
	done

	echo "Tagged images for GO_VERSION=${version}:"
	printf ' - %s\n' "${tags[@]}"

	if [[ "$PUSH" == "true" ]]; then
		for tag in "${tags[@]}"; do
			docker push "$tag"
		done
	fi
done
