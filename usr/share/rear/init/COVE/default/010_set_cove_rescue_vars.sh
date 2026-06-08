# 010_set_cove_rescue_vars.sh
#
# Set Cove Rescue Media specific variables when running inside the rescue system.

is_true "$RECOVERY_MODE" || return 0

function get_os_release_field() {
    local field="$1"
    grep "^$field=" /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"'
}

# Pre-1.5.0 Cove Rescue Media versions have the base Debian os-release (ID=debian) where
# VERSION_ID is the Debian release (e.g. "12"). In that case COVE_RESCUE_MEDIA_VERSION should stay empty.
if [ "$( get_os_release_field ID )" = "cove" ]; then
    COVE_RESCUE_MEDIA_VERSION="$( get_os_release_field VERSION_ID )"
    COVE_RESCUE_MEDIA_VARIANT="$( get_os_release_field VARIANT_ID )"
fi
