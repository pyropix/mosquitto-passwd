# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive BATS test suite with 17 test cases
- GitHub Actions CI/CD pipeline with linting, testing, security scanning
- Multi-platform Docker builds (linux/amd64, linux/arm64, linux/arm/v7)
- Dependabot configuration for automated dependency updates
- Username validation (alphanumeric, dots, hyphens, underscores only)
- Input validation for usernames (max 64 chars, no path traversal)
- Comprehensive error handling throughout passwd.sh
- Directory and dependency validation before execution
- Security warnings in README and script output
- Documentation for username requirements and file permissions
- CONTRIBUTING.md with contributor guidelines
- CHANGELOG.md to track version history
- GitHub issue templates (bug report, feature request)
- GitHub pull request template
- .dockerignore file to optimize build context
- Development section in README with testing and build instructions
- CI/CD badges in README
- Tests documentation in tests/README.md
- Password length customization via environment variable
- Unified build script using Docker Buildx

### Changed
- **BREAKING**: Container now runs as non-root user (UID/GID 1000)
- **BREAKING**: Publish scripts require DOCKER_USERNAME and DOCKER_PASSWORD env vars
- **BREAKING**: Invalid usernames are now rejected instead of silently processed
- File permissions changed from 755/775 to 600 for all password files
- Migrated from deprecated org.label-schema to OCI image annotations
- Pinned Alpine base image to version 3.19 (from latest)
- Improved password memory clearing with overwrite before unset
- Enhanced Dockerfile organization and added comments
- Improved README structure with security warnings prominent
- Build scripts now use unified buildx approach

### Fixed
- Fixed typo in README: "Prerequistes" → "Prerequisites"
- Fixed world-readable password files security issue
- Fixed missing error handling for file operations
- Fixed missing validation for /passwd directory
- Fixed hardcoded credentials in publish scripts
- Fixed lack of dependency checking

### Security
- Password files now created with 600 permissions (owner read/write only)
- Container runs as non-root user for improved security
- Username validation prevents path traversal and injection attacks
- Added security warnings about plaintext password storage
- Removed hardcoded Docker Hub credentials from scripts
- Added Trivy security scanning in CI/CD pipeline

## [0.2] - 2019

### Added
- Initial release
- Basic password generation using OpenSSL
- Mosquitto password file encryption
- JSON output for individual users
- Docker support
- ARM build support

### Features
- Generate passwords for single or multiple users
- OpenSSL-based random password generation (32 bytes, base64 encoded)
- Automatic Mosquitto password file encryption
- Individual JSON files per user
- Alpine Linux-based Docker image

## [0.1] - 2019

### Added
- Initial proof of concept

---

## How to Update This Changelog

When contributing, add your changes to the `[Unreleased]` section under the appropriate category:

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for security-related changes

Mark breaking changes with **BREAKING** prefix in the description.

[Unreleased]: https://github.com/burkhardm/mosquitto-passwd/compare/v0.2...HEAD
[0.2]: https://github.com/burkhardm/mosquitto-passwd/releases/tag/v0.2
[0.1]: https://github.com/burkhardm/mosquitto-passwd/releases/tag/v0.1
