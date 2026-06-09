#!/usr/bin/env bats

#
# Unit tests for udev functions
#

function setup_file() {
    REAR_SHARE_DIR="$(realpath "$BATS_TEST_DIRNAME/../../usr/share/rear")"
    export REAR_SHARE_DIR
}

function setup() {
    # shellcheck disable=SC1091
    source "$REAR_SHARE_DIR/lib/udev-functions.sh"
}

@test "Check device identifier type match: both dm-name-<dm_name>" {
    run check_device_identifier_type_match "dm-name-srcname" "dm-name-dstname"
    [ $status -eq 0 ]
}

@test "Check device identifier type match: both dm-uuid-<dm_uuid>" {
    run check_device_identifier_type_match "dm-uuid-srcuuid" "dm-uuid-dstuuid"
    [ $status -eq 0 ]
}

@test "Check device identifier type match: src is dm-name-<dm_name> and dst is dm-uuid-<dm_uuid>" {
    run check_device_identifier_type_match "dm-name-srcname" "dm-uuid-dstuuid"
    [ $status -eq 1 ]
}

@test "Check device identifier type match: src is dm-uuid-<dm_uuid> and dst is dm-name-<dm_name>" {
    run check_device_identifier_type_match "dm-uuid-srcuuid" "dm-name-dstname"
    [ $status -eq 1 ]
}

@test "Check device identifier type match: both have unexpected types" {
    run check_device_identifier_type_match "scsi-srcid" "ata-dstid"
    [ $status -eq 0 ]
}

@test "Get dm-uuid-<dm_uuid> identifier though dm-name-<dm_name> is returned first" {
    function UdevSymlinkName() {
        echo -n "/dev/ubuntu-vg/ubuntu-lv "
        echo -n "/dev/disk/by-dname/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/mapper/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-id/dm-name-ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-id/dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv "
        echo -n "/dev/disk/by-uuid/9d830822-b26a-4188-a9e4-40f6c8e6697b"
    }

    run get_new_device_identifier \
            "ubuntu--vg-ubuntu--lv" \
            "dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv"

    [ $status -eq 0 ]
    [ "$output" = "dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv" ]
}

@test "Get dm-name-<dm_name> identifier though dm-uuid-<dm_uuid> is returned first" {
    function UdevSymlinkName() {
        echo -n "/dev/ubuntu-vg/ubuntu-lv "
        echo -n "/dev/disk/by-dname/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/mapper/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-id/dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv "
        echo -n "/dev/disk/by-id/dm-name-ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-uuid/9d830822-b26a-4188-a9e4-40f6c8e6697b"
    }

    run get_new_device_identifier \
            "ubuntu--vg-ubuntu--lv" \
            "dm-name-ubuntu--vg-ubuntu--lv"

    [ $status -eq 0 ]
    [ "$output" = "dm-name-ubuntu--vg-ubuntu--lv" ]
}

@test "Get first /dev/disk/by-id identifier for unexpected types" {
    function UdevSymlinkName() {
        echo -n "/dev/ubuntu-vg/ubuntu-lv "
        echo -n "/dev/disk/by-dname/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/mapper/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-id/dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv "
        echo -n "/dev/disk/by-id/dm-name-ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-uuid/9d830822-b26a-4188-a9e4-40f6c8e6697b"
    }

    run get_new_device_identifier \
            "ubuntu--vg-ubuntu--lv" \
            "dm-mytype-ubuntu--vg-ubuntu--lv"

    [ $status -eq 0 ]
    [ "$output" = "dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv" ]
}

@test "Get dm-name-<dm_name> when there is no dm-uuid-<dm_uuid>" {
    function UdevSymlinkName() {
        echo -n "/dev/ubuntu-vg/ubuntu-lv "
        echo -n "/dev/disk/by-dname/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/mapper/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-id/dm-name-ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-uuid/9d830822-b26a-4188-a9e4-40f6c8e6697b"
    }

    run get_new_device_identifier \
            "ubuntu--vg-ubuntu--lv" \
            "dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv"

    [ $status -eq 0 ]
    [ "$output" = "dm-name-ubuntu--vg-ubuntu--lv" ]
}

@test "Get dm-uuid-<dm_uuid> when there is no dm-name-<dm_name>" {
    function UdevSymlinkName() {
        echo -n "/dev/ubuntu-vg/ubuntu-lv "
        echo -n "/dev/disk/by-dname/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/mapper/ubuntu--vg-ubuntu--lv "
        echo -n "/dev/disk/by-id/dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv "
        echo -n "/dev/disk/by-uuid/9d830822-b26a-4188-a9e4-40f6c8e6697b"
    }

    run get_new_device_identifier \
            "ubuntu--vg-ubuntu--lv" \
            "dm-name-ubuntu--vg-ubuntu--lv"

    [ $status -eq 0 ]
    [ "$output" = "dm-uuid-LVM-kmigtK0rFZKTG3R0ZSU7BoydFvlGyVyoy1gIcnddXb4Hl25dUk6elOgEQEkvCgiv" ]
}
