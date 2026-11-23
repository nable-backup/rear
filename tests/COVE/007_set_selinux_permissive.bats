#!/usr/bin/env bats

#
# Unit tests for choosing the systems where SELinux is set to permissive mode
#

function setup_file() {
    REAR_SHARE_DIR="$(realpath "$BATS_TEST_DIRNAME/../../usr/share/rear")"
    export REAR_SHARE_DIR
}

function setup() {
    # shellcheck disable=SC1091
    source "$REAR_SHARE_DIR/lib/linux-functions.sh"

    # shellcheck disable=SC2329
    function set_selinux_permissive() {
        echo "$1"
    }

    TARGET_FS_ROOT="$(mktemp -d)"
    mkdir -p "$TARGET_FS_ROOT/etc"
}

function teardown() {
    rm -rf "$TARGET_FS_ROOT"
}

function run_script() {
    local id=$1
    # shellcheck disable=SC2034
    OS_VENDOR=$2
    # shellcheck disable=SC2034
    OS_VERSION=$3

    printf '%s\n' "ID=$id" > "$TARGET_FS_ROOT/etc/os-release"

    run source "$REAR_SHARE_DIR/finalize/COVE/default/060_set_selinux_permissive.sh"
}

@test "SELinux is set to permissive on Azure Linux 4" {
    run_script azurelinux Fedora 4.0

    [ "$status" -eq 0 ]
    [ "$output" = "Azure Linux 4" ]
}

@test "SELinux is not changed on Azure Linux 3" {
    run_script azurelinux generic 3.0

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "SELinux is set to permissive on Fedora 44" {
    run_script fedora Fedora 44

    [ "$status" -eq 0 ]
    [ "$output" = "Fedora 44" ]
}

@test "SELinux is not changed on Fedora 43" {
    run_script fedora Fedora 43

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "SELinux is set to permissive on RHEL 10" {
    run_script rhel RedHatEnterpriseServer 10.0

    [ "$status" -eq 0 ]
    [ "$output" = "RedHatEnterpriseServer 10" ]
}

@test "SELinux is set to permissive on Rocky Linux 10" {
    run_script rocky RedHatEnterpriseServer 10.0

    [ "$status" -eq 0 ]
    [ "$output" = "RedHatEnterpriseServer 10" ]
}

@test "SELinux is not changed on RHEL 9" {
    run_script rhel RedHatEnterpriseServer 9.4

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
