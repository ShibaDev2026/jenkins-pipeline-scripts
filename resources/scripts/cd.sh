#!/usr/bin/env bash
# cd.sh — CD 入口

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/common/error-handler.sh"
source "${SCRIPT_DIR}/common/docker.sh"

BRANCH="${GIT_BRANCH:-unknown}"
# 去除 origin/ 前綴
BRANCH="${BRANCH#origin/}"

APP_NAME="${APP_NAME:?APP_NAME is required}"
APP_VERSION="${APP_VERSION:?APP_VERSION is required}"
BUILD_NUMBER="${BUILD_NUMBER:?BUILD_NUMBER is required}"
LANGUAGE="${LANGUAGE:-java}"

IMAGE_TAG="${APP_NAME}:${APP_VERSION}-${BUILD_NUMBER}"

echo "[cd] Branch: ${BRANCH}"
echo "[cd] Image: ${IMAGE_TAG}"

# ── Docker Build ──────────────────────────────────────────────────────────────
docker_build_if_needed() {
    case "${BRANCH}" in
        develop|main|prod)
            local build_args="--build-arg APP_NAME=${APP_NAME} \
                              --build-arg APP_VERSION=${APP_VERSION} \
                              --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                              --build-arg BRANCH=${BRANCH}"
            docker_build "${IMAGE_TAG}" "${LANGUAGE}" "${build_args}"
            ;;
        *)
            echo "[cd] Branch '${BRANCH}' — skipping Docker build."
            ;;
    esac
}

# ── Harbor Push ───────────────────────────────────────────────────────────────
harbor_push_if_needed() {
    case "${BRANCH}" in
        main|prod)
            echo "[cd] TODO: Harbor push not yet implemented."
            ;;
        *)
            echo "[cd] Branch '${BRANCH}' — skipping Harbor push."
            ;;
    esac
}

# ── Deploy ────────────────────────────────────────────────────────────────────
deploy_if_needed() {
    case "${BRANCH}" in
        prod)
            echo "[cd] TODO: Deploy not yet implemented."
            ;;
        *)
            echo "[cd] Branch '${BRANCH}' — skipping deploy."
            ;;
    esac
}

docker_build_if_needed
harbor_push_if_needed
deploy_if_needed

echo "[cd] CD completed."
