#
# Set SELINUX to permissive mode
#

test $( grep "SELINUX=enforcing" $TARGET_FS_ROOT/etc/selinux/config ) || return 0

sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' $TARGET_FS_ROOT/etc/selinux/config

LogUserOutput "WARNING:
During the recovery process, SELinux was temporarily set to permissive mode to allow the system to boot safely.
After verifying that your system is functioning correctly, it is necessary to re-enable SELinux enforcing mode."
