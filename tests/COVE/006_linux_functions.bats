#!/usr/bin/env bats

#
# Unit tests for Linux functions
#

function setup_file() {
    REAR_SHARE_DIR="$(realpath "$BATS_TEST_DIRNAME/../../usr/share/rear")"
    export REAR_SHARE_DIR
}

function setup() {
    # shellcheck disable=SC1091
    source "$REAR_SHARE_DIR/lib/linux-functions.sh"

    TEST_DIR="$(mktemp -d)"
    OS_RELEASE_FILE="$TEST_DIR/os-release"
}

function teardown() {
    rm -rf "$TEST_DIR"
}

@test "Get os-release field without quotes" {
    printf '%s\n' 'ID=azurelinux' 'VERSION_ID=4.0' > "$OS_RELEASE_FILE"

    run get_os_release_field ID "$OS_RELEASE_FILE"

    [ "$status" -eq 0 ]
    [ "$output" = "azurelinux" ]
}

@test "Get os-release field with double quotes" {
    printf '%s\n' 'ID="rhel"' 'VERSION_ID="10.0"' > "$OS_RELEASE_FILE"

    run get_os_release_field VERSION_ID "$OS_RELEASE_FILE"

    [ "$status" -eq 0 ]
    [ "$output" = "10.0" ]
}

@test "Get os-release field with single quotes" {
    printf '%s\n' "ID='fedora'" "VERSION_ID='44'" > "$OS_RELEASE_FILE"

    run get_os_release_field ID "$OS_RELEASE_FILE"

    [ "$status" -eq 0 ]
    [ "$output" = "fedora" ]
}

@test "Get os-release field that does not exist" {
    printf '%s\n' 'ID=fedora' > "$OS_RELEASE_FILE"

    run get_os_release_field VARIANT_ID "$OS_RELEASE_FILE"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "Get os-release field from a file that does not exist" {
    run get_os_release_field ID "$TEST_DIR/missing"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
