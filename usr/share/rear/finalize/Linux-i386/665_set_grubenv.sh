# Set up grubenv (GRUB environment block)

function set_grubenv() {
    local grub_editenv
    if ! grub_editenv=$(get_grub_editenv); then
        LogPrintError "Failed to set grubenv: neither grub-editenv nor grub2-editenv was found"
        return 1
    fi

    # It is essential to set up the environment block in the reserved btrfs sector
    # See https://en.opensuse.org/GRUB#GRUB2_on_btrfs_/boot for more details
    run_in_target_root "\"$grub_editenv\" - unset dummy"

    local exit_code=0
    local var_value
    while IFS= read -r var_value; do
        local var="${var_value%=*}"
        # env_block is read-only after initialization
        if [ "$var" = "env_block" ] ; then
            continue
        fi
        if ! run_in_target_root "\"$grub_editenv\" - set \"$var_value\""; then
            LogPrintError "Failed to set '$var_value' to grubenv"
            exit_code=1
        fi
    done < "$GRUBENV_PATH"

    if [ $exit_code -eq 0 ]; then
        Log "grubenv was set successfully"
    fi

    return $exit_code
}

if is_grubenv_set_required; then
    set_grubenv
fi
