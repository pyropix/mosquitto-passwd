# Contributing to mosquitto-passwd

Thank you for your interest in contributing to mosquitto-passwd! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Commit Guidelines](#commit-guidelines)

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Environment details** (OS, Docker version, etc.)
- **Logs or error messages** if applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- **Clear use case** - Why is this enhancement needed?
- **Proposed solution** - How would you like it to work?
- **Alternatives considered** - What other approaches did you think about?

### Pull Requests

Pull requests for bug fixes, enhancements, and documentation improvements are always welcome!

## Development Setup

### Prerequisites

- Docker
- Git
- BATS (for running tests)
- ShellCheck (optional, for linting)

### Local Development

1. **Fork and clone the repository**

```bash
git clone https://github.com/YOUR_USERNAME/mosquitto-passwd.git
cd mosquitto-passwd
```

2. **Create a feature branch**

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

3. **Make your changes**

Edit the relevant files. The main files are:
- `passwd.sh` - Main password generation script
- `Dockerfile` - Container definition
- `tests/passwd_test.sh` - Test suite

4. **Test your changes**

```bash
# Run tests
bats tests/passwd_test.sh

# Build Docker image
docker build -t mosquitto-passwd:test .

# Test the image
mkdir -p test-passwd
docker run --rm -v $(pwd)/test-passwd:/passwd mosquitto-passwd:test
```

5. **Lint your code**

```bash
# ShellCheck for shell scripts
shellcheck passwd.sh *.sh

# Hadolint for Dockerfile
docker run --rm -i hadolint/hadolint < Dockerfile
```

## Pull Request Process

1. **Update tests** - Add or update tests for your changes
2. **Update documentation** - Update README.md if needed
3. **Run the test suite** - Ensure all tests pass
4. **Update CHANGELOG.md** - Add your changes under "Unreleased"
5. **Create the PR** with a clear description of changes
6. **Wait for review** - A maintainer will review your PR
7. **Address feedback** - Make requested changes if any
8. **Merge** - Once approved, your PR will be merged!

### PR Checklist

- [ ] Tests pass locally
- [ ] Code follows project style guidelines
- [ ] Documentation updated (if applicable)
- [ ] CHANGELOG.md updated
- [ ] Commit messages follow convention
- [ ] No merge conflicts
- [ ] ShellCheck passes (no warnings)
- [ ] Hadolint passes for Dockerfile changes

## Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Always use `set -euo pipefail` for error handling
- Use `local` for function variables
- Quote all variable expansions: `"$variable"`
- Use meaningful variable names
- Add comments for complex logic
- Follow existing code style

### Dockerfile

- Use specific version tags (not `latest`)
- Run as non-root user
- Minimize layers where appropriate
- Add comments for clarity
- Use OCI annotations for metadata
- Follow Docker best practices

### Documentation

- Use clear, concise language
- Include code examples where helpful
- Update table of contents if adding sections
- Use proper Markdown formatting
- Spell check your content

## Testing

### Writing Tests

Tests use BATS (Bash Automated Testing System). Test file: `tests/passwd_test.sh`

Example test:

```bash
@test "description of what is being tested" {
    # Arrange
    setup_test_data

    # Act
    run command_to_test argument1 argument2

    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" =~ "expected string" ]]
}
```

### Test Coverage

Aim to test:
- Happy path scenarios
- Error conditions
- Edge cases
- Security validations
- File permissions
- Output formats

### Running Tests

```bash
# Run all tests
bats tests/passwd_test.sh

# Run specific test
bats -f "test name pattern" tests/passwd_test.sh

# Verbose output
bats -t tests/passwd_test.sh
```

## Commit Guidelines

### Commit Message Format

Use conventional commit format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code style (formatting, no logic change)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks
- `ci` - CI/CD changes
- `security` - Security improvements

**Examples:**

```
feat(passwd): add password length option

Add PASSWORD_LENGTH environment variable to allow users to customize
the generated password length (default: 32 bytes).

Closes #123
```

```
fix(docker): correct file permissions for non-root user

Files were being created with incorrect ownership when running as
non-root user. Fixed by using --chown flag in COPY instruction.

Fixes #456
```

```
docs: update README with username requirements

Added section documenting username validation rules and providing
examples of valid usernames.
```

## Questions?

If you have questions about contributing, feel free to:

- Open an issue with the `question` label
- Check existing issues and discussions
- Review closed PRs for examples

Thank you for contributing! 🎉
