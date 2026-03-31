#!/usr/bin/env bash
# common/error-handler.sh — 共用錯誤處理

set -euo pipefail

# ── trap_error：非預期 exit 時自動捕捉，輸出 script 名稱 + 行號 + exit code ──
trap_error() {
    local exit_code=$?
    local line_number=${1:-unknown}
    # BASH_SOURCE[1] 取得呼叫者的 script 名稱（error-handler.sh 本身為 [0]）
    local script_name
    script_name="$(basename "${BASH_SOURCE[1]:-unknown}")"
    echo "[ERROR] ${script_name} failed at line ${line_number} with exit code ${exit_code}" >&2
    exit "${exit_code}"
}

trap 'trap_error ${LINENO}' ERR

# ── report_error：業務層結構化錯誤輸出，供各 stage script 主動呼叫 ──────────
# 用途：讓 console log 可快速掃描，區分「哪個 stage」「什麼問題」
# 參數：
#   stage   — 所在 stage 名稱，例：BUILD / TEST / DOCKER / HARBOR / SCAN / GIT
#   code    — 錯誤碼（3 位數字），例：001
#   message — 說明文字，應包含診斷提示
# 範例：report_error "DOCKER" "001" "JAR not found. Check Archive stage output."
report_error() {
    local stage="${1}"
    local code="${2}"
    local message="${3}"
    echo "" >&2
    echo "╔══════════════════════════════════════════════╗" >&2
    echo "║  PIPELINE ERROR                              ║" >&2
    echo "╠══════════════════════════════════════════════╣" >&2
    printf "║  Stage   : %-34s║\n" "${stage}"            >&2
    printf "║  Code    : %-34s║\n" "${stage}-${code}"    >&2
    printf "║  Message : %-34s║\n" "${message}"          >&2
    echo "╚══════════════════════════════════════════════╝" >&2
    echo "" >&2
}
