# Changelog

本檔案依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.0.0/) 格式，
版號遵循 [Semantic Versioning（語意化版本）](https://semver.org/lang/zh-TW/)。

## [Unreleased]

---

## [1.0.0] - 2026-03-12

### Added
- jenkins-pipeline Shared Library 初始版本，統一管理所有專案 CI/CD 流程
- `ciPipeline.groovy`：Pipeline 統一入口，各專案 Jenkinsfile 僅需傳入 `githubCredentials`
- `detect.sh`：自動偵測語言（Java / Node / Python）與 Build Tool，輸出 KEY=VALUE 格式
- `ci.sh`：CI 流程入口（standalone 用途）
- `cd.sh`：CD 流程入口，支援 `docker-build | harbor-push | deploy | all` stage 參數
- `common/error-handler.sh`：共用錯誤處理（trap ERR）
- `common/docker.sh`：Docker Build 共用邏輯，支援三層 Dockerfile 查找優先序
- `common/git-tag.sh`：Git Tag 共用邏輯
- `common/archive-base.sh`：release/backup 搬移共用邏輯
- `java/java-build.sh`：Maven / Gradle 條件判斷與執行
- `java/java-test.sh`：測試執行，依 branch 決定範圍（Unit / Coverage / Integration / Security）
- `java/java-archive.sh`：JAR 版本命名管理，結果寫入 `.pipeline/build.env`
- `dockerfiles/Dockerfile-java`：Java 應用標準 Docker Image 定義
- Pipeline Stages：Checkout → Load Scripts → Detect → Build → Test → Archive → Docker Build
- Load Scripts 機制：透過 `libraryResource()` 將 scripts/dockerfiles 寫入 Agent `.pipeline/` 目錄
- 產出物命名規則：依 branch 自動加入對應後綴（SNAPSHOT / RC / 正式版）
- Git Tag 策略：develop/main/feature branch 由 Jenkins 自動打 tag，prod 由開發者手動標記

### Fixed
- 修正 `archive-base.sh` / `git-tag.sh` 被 source 時 `BASH_SOURCE` 路徑錯誤
- 修正 Agent 無法存取 Shared Library scripts 的問題（改以 `libraryResource()` 寫入 Agent workspace）
- 修正 artifact 命名出現重複 SNAPSHOT 後綴的問題

### Docs
- 新增 README：使用方式、目錄結構、語言偵測邏輯、版本管理說明

[Unreleased]: https://github.com/ShibaDev2026/jenkins-pipeline/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ShibaDev2026/jenkins-pipeline/releases/tag/v1.0.0
