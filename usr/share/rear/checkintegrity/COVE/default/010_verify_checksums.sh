# Check md5sum files

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

    local all_pass=1
    for md5sum_file in "${md5sum_files[@]}" ; do
        local path="$VAR_DIR/layout/config/$md5sum_file"

        # Skip when there are no checksums for this file
        if ! test -s "$path"; then
            LogUserOutput "Warning: '$path' not found. Skipped."
            continue
        fi

        LogUserOutput "Verifying checksums from '$path'..."

        local md5sum_stdout
        if ! md5sum_stdout="$( md5sum -c --quiet < "$path" )" ; then
            LogUserOutput "Restored file(s) do not fully match the recreated system."
            LogUserOutput "$( sed -e 's/^/  /' <<< "$md5sum_stdout" )"
            LogUserOutput "Verification failed: checksums do not match for file(s) in '$md5sum_file'."
            all_pass=0
        else
            LogUserOutput "Verification passed: checksums match in '$md5sum_file'."
        fi
    done

    if [ $all_pass -eq 1 ]; then
        LogUserOutput ""
        LogUserOutput "Verification passed: all checksums match."
    else
        Error "Verification failed: checksums did NOT match."
    fi
}

verify_checksums
