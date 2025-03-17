#
# save install path
#

echo "$(readlink -f "${COVE_INSTALL_DIR}")" > "${VAR_DIR}/recovery/cove_install_dir"
