#!/usr/bin/env bats

# Test suite for passwd.sh
# Run with: bats tests/passwd_test.sh

setup() {
    # Create a temporary directory for testing
    export TEST_DIR="$(mktemp -d)"
    export TEST_PASSWD_DIR="$TEST_DIR/passwd"
    mkdir -p "$TEST_PASSWD_DIR"

    # Copy the script to test
    cp passwd.sh "$TEST_DIR/test_passwd.sh"

    # Modify script to use test directory
    sed -i "s|/passwd|$TEST_PASSWD_DIR|g" "$TEST_DIR/test_passwd.sh"
    chmod +x "$TEST_DIR/test_passwd.sh"
}

teardown() {
    # Clean up test directory
    rm -rf "$TEST_DIR"
}

@test "Script exits with error when passwd directory doesn't exist" {
    rm -rf "$TEST_PASSWD_DIR"
    run "$TEST_DIR/test_passwd.sh"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "does not exist" ]]
}

@test "Script creates password file for default user" {
    run "$TEST_DIR/test_passwd.sh"
    [ "$status" -eq 0 ]
    [ -f "$TEST_PASSWD_DIR/mosquitto.plain" ]
    [ -f "$TEST_PASSWD_DIR/mosquitto.passwd" ]
    [ -f "$TEST_PASSWD_DIR/user_passwd.json" ]
}

@test "Generated password files have correct permissions (600)" {
    run "$TEST_DIR/test_passwd.sh"
    [ "$status" -eq 0 ]

    # Check plain file permissions
    perms=$(stat -c "%a" "$TEST_PASSWD_DIR/mosquitto.plain")
    [ "$perms" = "600" ]

    # Check passwd file permissions
    perms=$(stat -c "%a" "$TEST_PASSWD_DIR/mosquitto.passwd")
    [ "$perms" = "600" ]

    # Check JSON file permissions
    perms=$(stat -c "%a" "$TEST_PASSWD_DIR/user_passwd.json")
    [ "$perms" = "600" ]
}

@test "Script creates files for multiple users" {
    run "$TEST_DIR/test_passwd.sh" alice bob charlie
    [ "$status" -eq 0 ]
    [ -f "$TEST_PASSWD_DIR/alice_passwd.json" ]
    [ -f "$TEST_PASSWD_DIR/bob_passwd.json" ]
    [ -f "$TEST_PASSWD_DIR/charlie_passwd.json" ]
}

@test "Script rejects empty username" {
    run "$TEST_DIR/test_passwd.sh" ""
    [ "$status" -ne 0 ]
    [[ "$output" =~ "cannot be empty" ]]
}

@test "Script rejects username with invalid characters" {
    run "$TEST_DIR/test_passwd.sh" "user@domain"
    [[ "$output" =~ "invalid characters" ]]
}

@test "Script rejects username with path traversal" {
    run "$TEST_DIR/test_passwd.sh" "../evil"
    [[ "$output" =~ "invalid characters" ]]
}

@test "Script rejects username that is too long" {
    long_username=$(printf 'a%.0s' {1..65})
    run "$TEST_DIR/test_passwd.sh" "$long_username"
    [[ "$output" =~ "too long" ]]
}

@test "Script accepts valid usernames with dots, hyphens, and underscores" {
    run "$TEST_DIR/test_passwd.sh" "user.test" "user-test" "user_test"
    [ "$status" -eq 0 ]
    [ -f "$TEST_PASSWD_DIR/user.test_passwd.json" ]
    [ -f "$TEST_PASSWD_DIR/user-test_passwd.json" ]
    [ -f "$TEST_PASSWD_DIR/user_test_passwd.json" ]
}

@test "Generated JSON file has correct structure" {
    run "$TEST_DIR/test_passwd.sh" testuser
    [ "$status" -eq 0 ]

    # Check JSON structure
    json_file="$TEST_PASSWD_DIR/testuser_passwd.json"
    grep -q '"Username":"testuser"' "$json_file"
    grep -q '"Password":"' "$json_file"
}

@test "Plain text and encrypted files contain username" {
    run "$TEST_DIR/test_passwd.sh" testuser
    [ "$status" -eq 0 ]

    grep -q "testuser:" "$TEST_PASSWD_DIR/mosquitto.plain"
    grep -q "testuser:" "$TEST_PASSWD_DIR/mosquitto.passwd"
}

@test "Encrypted password format is correct (should contain hash)" {
    run "$TEST_DIR/test_passwd.sh" testuser
    [ "$status" -eq 0 ]

    # Mosquitto passwd format should have $6$ (SHA-512) or $7$ (Argon2)
    grep -E "testuser:\\\$[67]\\\$" "$TEST_PASSWD_DIR/mosquitto.passwd"
}

@test "Script warns about plaintext password storage" {
    run "$TEST_DIR/test_passwd.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "WARNING" ]]
    [[ "$output" =~ "Plain-text passwords" ]]
}

@test "Script handles passwd directory without write permissions" {
    chmod 555 "$TEST_PASSWD_DIR"
    run "$TEST_DIR/test_passwd.sh"
    chmod 755 "$TEST_PASSWD_DIR"  # Restore for cleanup

    [ "$status" -eq 1 ]
    [[ "$output" =~ "not writable" ]]
}

@test "Script continues processing valid users when one fails" {
    run "$TEST_DIR/test_passwd.sh" "valid_user" "../invalid" "another_valid"

    # Should create files for valid users
    [ -f "$TEST_PASSWD_DIR/valid_user_passwd.json" ]
    [ -f "$TEST_PASSWD_DIR/another_valid_passwd.json" ]

    # Should warn about failed user
    [[ "$output" =~ "invalid" ]]
}
