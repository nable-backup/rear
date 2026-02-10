# Check md5sum files

# shellcheck disable=SC2168

LogUserOutput "Checking if certain restored files are consistent with the recreated system"

local md5sum_files=()

case "$COVE_INTEGRITY_CHECK" in
    all)
        md5sum_files+=(files.md5sum cove-files.md5sum)
        ;;
    *binaries*)
        md5sum_files+=(cove-files.md5sum)
        ;;
    *configs*)
        md5sum_files+=(files.md5sum)
        ;;
esac

for md5sum_file in "${md5sum_files[@]}" ; do
    local path="$VAR_DIR/layout/config/$md5sum_file"

    # Skip when there are no checksums for this file:
    test -s "$path" || continue

    LogUserOutput "Verifying hash sums from '$path'"

    local md5sum_stdout
    if ! md5sum_stdout="$( md5sum -c --quiet < "$path" )" ; then
        LogUserOutput "Restored files do not fully match the recreated system"
        LogUserOutput "$( sed -e 's/^/  /' <<< "$md5sum_stdout" )"
        Error "Binary verification failed: checksums do not match for $md5sum_file"
    fi
done

LogUserOutput "Binary verification passed: all checksums match successfully"
