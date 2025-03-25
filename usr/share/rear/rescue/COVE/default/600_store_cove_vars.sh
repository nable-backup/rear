# Store Cove variables for recovery:
# - Real install directory to install the Backup Manager at the same place
# - Timestamp to find the corresponding FileSystem backup session

cat <<EOF >>"$ROOTFS_DIR/etc/rear/rescue.conf"

# from rescue/COVE/default/600_store_cove_vars.sh
COVE_REAL_INSTALL_DIR="$(readlink -f "${COVE_INSTALL_DIR}")"
COVE_TIMESTAMP="${COVE_TIMESTAMP}"
EOF
