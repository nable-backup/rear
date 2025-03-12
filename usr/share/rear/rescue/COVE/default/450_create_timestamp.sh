#
# create timestamp
#

[ -z "${COVE_TIMESTAMP}" ] || echo "${COVE_TIMESTAMP}" > "${VAR_DIR}/recovery/cove_timestamp"
