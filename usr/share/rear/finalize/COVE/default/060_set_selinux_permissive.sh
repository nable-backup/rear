#
# Set SELinux to permissive mode
#

os_major="${OS_VERSION%%.*}"

# Azure Linux has ID_LIKE=fedora, so OS_VENDOR is Fedora. Use the ID from os-release instead.
os_id=$( get_os_release_field ID "$TARGET_FS_ROOT/etc/os-release" )

if [ "$os_id/$os_major" = "azurelinux/4" ] ; then
    os_name="Azure Linux"
else
    case "$OS_VENDOR/$os_major" in
        ("Fedora/44"|"RedHatEnterpriseServer/10")
            os_name="$OS_VENDOR"
            ;;
        (*)
            return 0
            ;;
    esac
fi

set_selinux_permissive "$os_name $os_major"
