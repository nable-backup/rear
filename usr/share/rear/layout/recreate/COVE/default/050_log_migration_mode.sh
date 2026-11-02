#
# Log whether the migration is being performed primarily to make this
# available for the checkintegrity command after the target machine reboots.
#

if is_true "$MIGRATION_MODE"; then
    Log "Migration mode is enabled"
else
    Log "Migration mode is disabled"
fi
