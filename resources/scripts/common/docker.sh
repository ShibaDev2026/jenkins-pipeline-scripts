#!/usr/bin/env bash
# common/docker.sh — Docker Build 共通

source "$(dirname "${BASH_SOURCE[0]}")/error-handler.sh"

# 優先順序：
# 1. 專案根目錄 Dockerfile-{language}
# 2. 專案根目錄 Dockerfile
# 3. pipeline 預設 Dockerfile（由 ciPipeline.groovy 寫入 .pipeline/dockerfiles/）
resolve_dockerfile() {
    local language="${1}"
    local workspace="${WORKSPACE}"
    local lib_root="${WORKSPACE}/.pipeline/dockerfiles"

    if [[ -f "${workspace}/Dockerfile-${language}" ]]; then
        echo "${workspace}/Dockerfile-${language}"
    elif [[ -f "${workspace}/Dockerfile" ]]; then
        echo "${workspace}/Dockerfile"
    else
        echo "${lib_root}/Dockerfile-${language}"
    fi
}

docker_build() {
    local image_name="${1}"
    local language="${2}"
    local build_args="${3:-}"

    local dockerfile
    dockerfile="$(resolve_dockerfile "${language}")"

    echo "[docker] Using Dockerfile: ${dockerfile}"
    echo "[docker] Building image: ${image_name}"

    DOCKER_BUILDKIT=0 docker build \
        -f "${dockerfile}" \
        ${build_args} \
        -t "${image_name}" \
        "${WORKSPACE}"

    # build 完成後，為 base image 建立 shiba/base/ 別名，方便 docker images 識別用途
    tag_base_image "${dockerfile}" "${build_args}"
}

# 解析 Dockerfile 的 FROM 行，為 base image 打 shiba/base/ 識別別名
# 別名格式：shiba/base/{image-name}:{tag}，例：shiba/base/eclipse-temurin:17-jre-jammy
tag_base_image() {
    local dockerfile="${1}"
    local build_args="${2:-}"

    # 讀取 FROM 行樣板（第一個 FROM，跳過多階段後段）
    local from_template
    from_template="$(awk '/^FROM/{print $2; exit}' "${dockerfile}")"
    [[ -z "${from_template}" ]] && return 0

    # 讀取 Dockerfile ARG 定義的預設版本號
    local runtime_version
    runtime_version="$(awk '/^ARG RUNTIME_VERSION/{split($2,a,"="); print a[2]; exit}' "${dockerfile}")"
    runtime_version="${runtime_version:-17}"

    # 若 build_args 有傳入 RUNTIME_VERSION，優先覆蓋
    if echo "${build_args}" | grep -q "RUNTIME_VERSION="; then
        runtime_version="$(echo "${build_args}" | grep -oE 'RUNTIME_VERSION=[^ ]+' | cut -d= -f2)"
    fi

    # 將 Dockerfile 變數替換為實際版本號
    local base_image="${from_template//\$\{RUNTIME_VERSION\}/${runtime_version}}"

    # 拆解 image name 與 tag，建立 shiba/base/ 別名
    local image_name image_tag alias_tag
    image_name="$(echo "${base_image}" | cut -d: -f1 | awk -F/ '{print $NF}')"
    image_tag="$(echo "${base_image}" | cut -d: -f2-)"
    alias_tag="shiba/base/${image_name}:${image_tag}"

    echo "[docker] Tagging base: ${base_image} → ${alias_tag}"
    docker tag "${base_image}" "${alias_tag}" 2>/dev/null \
        || echo "[docker] WARNING: base image tag skipped (${base_image} not in local cache)"
}
