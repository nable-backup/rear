# 010_set_cove_rescue_vars.sh
#
# Set Cove Rescue Media specific variables when running inside the rescue system.

is_true "$RECOVERY_MODE" || return 0

# Pre-1.5.0 Cove Rescue Media versions have the base Debian os-release (ID=debian) where
# VERSION_ID is the Debian release (e.g. "12"). In that case COVE_RESCUE_MEDIA_VERSION should stay empty.
if [ "$( get_os_release_field ID /etc/os-release )" = "cove" ]; then
    COVE_RESCUE_MEDIA_VERSION="$( get_os_release_field VERSION_ID /etc/os-release )"
    COVE_RESCUE_MEDIA_VARIANT="$( get_os_release_field VARIANT_ID /etc/os-release )"
fi
