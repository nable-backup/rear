local archive_file="$TMP_DIR/$OUTPUT_PREFIX-state.tar.gz"

tar $v -czf "$archive_file" -C $ROOTFS_DIR --exclude="$VAR_DIR/output/*" etc/rear "$VAR_DIR" || Error "Failed to create archive '$archive_file'"

RESULT_FILES+=( "$archive_file" )
