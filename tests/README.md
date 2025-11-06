# Tests

This directory contains automated tests for the mosquitto-passwd utility.

## Test Framework

Tests are written using [BATS](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

## Running Tests Locally

### Prerequisites

Install BATS:

```bash
# On macOS
brew install bats-core

# On Ubuntu/Debian
sudo apt-get install bats

# Using npm
npm install -g bats

# Using git submodule
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local
```

### Run Tests

```bash
# Run all tests
bats tests/passwd_test.sh

# Run with verbose output
bats -t tests/passwd_test.sh

# Run specific test
bats -f "password files have correct permissions" tests/passwd_test.sh
```

## Test Coverage

The test suite covers:

- ✅ Default user creation
- ✅ Multiple user creation
- ✅ File permissions (600)
- ✅ Username validation (empty, invalid characters, path traversal, length)
- ✅ JSON file structure
- ✅ Encrypted password format
- ✅ Error handling (missing directory, write permissions)
- ✅ Security warnings
- ✅ Partial failure handling (valid + invalid users)

## CI/CD

Tests are automatically run in GitHub Actions on every push and pull request. See `.github/workflows/ci.yml` for details.

## Writing New Tests

Follow the BATS testing pattern:

```bash
@test "description of test" {
    run command_to_test
    [ "$status" -eq 0 ]  # Check exit code
    [[ "$output" =~ "expected string" ]]  # Check output
}
```

See the [BATS documentation](https://bats-core.readthedocs.io/) for more details.
