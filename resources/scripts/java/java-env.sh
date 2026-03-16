#!/usr/bin/env bash
# java/java-env.sh — 依專案宣告的 Java 版本切換 JAVA_HOME
# 由 ci.sh source，在執行 java-build.sh 之前套用

WORKSPACE="${WORKSPACE:-$(pwd)}"

# ── 讀取 Java 版本 ─────────────────────────────────────────────────────────────
detect_java_version() {
    if [[ -f "${WORKSPACE}/pom.xml" ]]; then
        # 優先讀 <java.version>，其次讀 <maven.compiler.source>
        local version
        version=$(grep -m1 '<java.version>' "${WORKSPACE}/pom.xml" \
            | sed 's/.*<java.version>\(.*\)<\/java.version>.*/\1/' | tr -d '[:space:]')
        if [[ -z "${version}" ]]; then
            version=$(grep -m1 '<maven.compiler.source>' "${WORKSPACE}/pom.xml" \
                | sed 's/.*<maven.compiler.source>\(.*\)<\/maven.compiler.source>.*/\1/' | tr -d '[:space:]')
        fi
        echo "${version}"
    elif [[ -f "${WORKSPACE}/build.gradle" ]]; then
        # 讀 sourceCompatibility = '17' 或 JavaVersion.VERSION_17
        grep -m1 'sourceCompatibility' "${WORKSPACE}/build.gradle" \
            | grep -oE '[0-9]+' | tail -1
    fi
}

JAVA_VERSION="$(detect_java_version)"
echo "[java-env] Detected Java version: ${JAVA_VERSION:-not specified, fallback to 21}"

# ── 對應 JAVA_HOME（未來新增 JDK 版本只需在此擴充）─────────────────────────────
case "${JAVA_VERSION}" in
    1.8|8)  export JAVA_HOME="${JAVA8_HOME}"  ;;
    11)     export JAVA_HOME="${JAVA11_HOME}" ;;
    17)     export JAVA_HOME="${JAVA17_HOME}" ;;
    21|"")  export JAVA_HOME="${JAVA21_HOME}" ;;
    *)
        echo "[ERROR] Unsupported Java version: ${JAVA_VERSION}. Supported: 8, 11, 17, 21" >&2
        exit 1
        ;;
esac

export PATH="${JAVA_HOME}/bin:${PATH}"
echo "[java-env] JAVA_HOME set to: ${JAVA_HOME}"
echo "[java-env] $(java -version 2>&1 | head -1)"
