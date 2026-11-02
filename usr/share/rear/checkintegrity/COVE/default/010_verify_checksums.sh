# Check md5sum files

function was_migration() {
    local live_log_path="$COVE_INSTALL_DIR/var/log/rear/rear-live-log.log"
    if [ ! -f "$live_log_path" ]; then
        return 1
    fi

    grep -q "Migration mode is enabled" "$live_log_path"
}

function verify_checksums() {
    local md5sum_files=()

    case "$COVE_CHECK_INTEGRITY" in
        all)
            md5sum_files+=(files.md5sum cove-files.md5sum)
            ;;
        *binaries*)
            md5sum_files+=(cove-files.md5sum)
            ;;&
        *configs*)
            md5sum_files+=(files.md5sum)
            ;;
    esac

    if [ ${#md5sum_files[@]} -eq 0 ]; then
        LogUserOutput "Nothing to check. See COVE_CHECK_INTEGRITY in 'default.conf'."
        return 0
    fi

    LogUserOutput "Checking if certain restored files are consistent with the recreated system..."

    local exclude_patched_files=0
    if was_migration; then
        LogUserOutput "Migration detected: files patched by ReaR will be excluded from the check."
        exclude_patched_files=1
    fi

    local all_pass=1
    for md5sum_file in "${md5sum_files[@]}" ; do
        local path="$VAR_DIR/layout/config/$md5sum_file"

        if ! test -f "$path"; then
            LogUserOutput "Warning: '$path' not found. Skipped."
            continue
        elif ! test -s "$path"; then
            LogUserOutput "Warning: no checksums in '$path'. Skipped."
            continue
        fi

        LogUserOutput "Verifying checksums from '$path'..."

        if is_true "$exclude_patched_files"; then
            local new_path="$path.modified"
            cp "$path" "$new_path" || return
            path="$new_path"

            pushd / >/dev/null
            local patched_file
            for patched_file in $FILES_TO_PATCH_PATTERNS; do
                if [ ! -f "$patched_file" ]; then
                    continue
                fi
                patched_file=$( echo "$patched_file" | sed 's/[][\/$*.^]/\\&/g' )
                sed -i "/^[[:xdigit:]]\{32\}[[:space:]]\+\/$patched_file\$/d" "$path"
            done
            popd >/dev/null || return
        fi

        local md5sum_stdout
        if ! test -s "$path"; then
            LogUserOutput "Warning: no checksums in '$path'. Skipped."
        elif ! md5sum_stdout="$( md5sum -c --quiet < "$path" )" ; then
            LogUserOutput "Restored file(s) do not fully match the recreated system."
            LogUserOutput "$( sed -e 's/^/  /' <<< "$md5sum_stdout" )"
            LogUserOutput "Verification failed: checksums do not match for file(s) in '$md5sum_file'."
            all_pass=0
        else
            LogUserOutput "Verification passed: checksums match in '$md5sum_file'."
        fi

        if is_true "$exclude_patched_files"; then
            rm -f "$path"
        fi
    done

    if [ $all_pass -eq 1 ]; then
        LogUserOutput ""
        LogUserOutput "Verification passed: all checksums match."
    else
        Error "Verification failed: checksums did NOT match."
    fi
}

verify_checksums || Error "Checksum verification failed."
