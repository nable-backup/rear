#
# Set SELinux to permissive mode
#

[ "${OS_VERSION%%.*}" = "10" ] || return 0

set_selinux_permissive "${OS_VENDOR} ${OS_VERSION%%.*}"
