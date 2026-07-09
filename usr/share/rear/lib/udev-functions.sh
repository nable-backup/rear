# Return 0 if source and target device identifiers are of the same type:
# either both dm-uuid-<dm_name> or both dm-name-<dm_name>, return 1 othwerwise.
# Return 0 for non device-mapper identifiers.
# $1: source device identifier
# $2: target device identifier
function check_device_identifier_type_match() {
    local src_id="$1"
    local dst_id="$2"

    if [[ $src_id =~ ^(dm-uuid-|dm-name-) ]]; then
        local type="${BASH_REMATCH[1]}"
        [[ $dst_id =~ ^$type ]]
        return $?
    fi

    return 0
}

# Get actual device identifier
# $1: source device name
# $2: source device identifier
function get_new_device_identifier() {
    local dev_name="$1"
    local id="$2"
    local new_id=""

    local symlinks=""
    symlinks=$(UdevSymlinkName "$dev_name")
    # shellcheck disable=SC2086
    set -- $symlinks
    while [ $# -gt 0 ]; do
        if [[ $1 =~ /dev/disk/by-id ]]; then
            # bingo, we found what we are looking for
            new_id=${1#/dev/disk/by-id/} # cciss-3600508b1001cd2b56e1aeab1f82dd70d

            # Respect device identifier type to avoid replacing dm-uuid-<dm_uuid>
            # with dm-name-<dm_name>, and vice versa.
            if check_device_identifier_type_match "$id" "$new_id"; then
                echo "$new_id"
                return 0
            fi
        fi
        shift
    done

    echo "$new_id"
}
