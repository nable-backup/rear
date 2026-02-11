# Save a hash of files that would warrant a new rescue image when changed.

# shellcheck disable=SC2168,SC2207

if [ "$WORKFLOW" = "checklayout" ] ; then
    return 0
fi

local obj
local config_files=()
for obj in "${CHECK_CONFIG_FILES[@]}" ; do
    if [ -d "$obj" ] ; then
        config_files+=( $( find "$obj" -type f ) )
    elif [ -e "$obj" ] ; then
        config_files+=( "$obj")
    fi
done
md5sum "${config_files[@]}" > "$VAR_DIR/layout/config/files.md5sum"

# For COVE backup, additionally verify binaries if enabled
local item
local cove_files=()
if [ "$WORKFLOW" = "mksystemstate" ] && is_true "$COVE_VERIFY_BINARIES" ; then
    for item in "${COVE_VERIFY_PATHS[@]}" ; do
        if [ -d "$item" ] ; then
            while IFS= read -r -d '' file ; do
                cove_files+=( "$file" )
            done < <(find "$item" -type f -print0)
        elif [ -f "$item" ] ; then
            cove_files+=( "$item" )
        fi
    done

    # See finalize/COVE/Debian/620_upgrade_bootloaders.sh to find out when
    # signed binaries are copied from the Cove Rescue Media to the target fs
    # on systems running Debian 10. The logic is simplified because UEFI_BOOTLOADER
    # path is unknown by this time.
    if [ "$OS_VENDOR_VERSION" = "Debian/10" ] && is_true "$USING_UEFI_BOOTLOADER"; then
        local exclusions=(
            /boot/efi/EFI/debian/grubx64.efi
            /boot/efi/EFI/debian/shimx64.efi
        )
        local exclusion
        for exclusion in "${exclusions[@]}"; do
            cove_files=( $( RmInArray "$exclusion" "${cove_files[@]}" ) )
        done
    fi
fi

cove_md5sum_file="$VAR_DIR/layout/config/cove-files.md5sum"
: > "$cove_md5sum_file"
for filepath in "${cove_files[@]}"; do
    md5sum "$filepath" >> "$cove_md5sum_file"
done
