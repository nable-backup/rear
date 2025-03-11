# 400_restore_with_cove.sh
#
#

# ANSI color escape sequences
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No color

# Required installation parameters
#COVE_INSTALLER_URL=""
COVE_INSTALLATION_TOKEN=""

COVE_CLIENT_TOOL="${COVE_INSTALL_DIR}/bin/ClientTool"
COVE_INSTALLER_PATH="${TMPDIR:=/tmp}/mxb-linux-x86_64.run"

function cove_wait_for() {
    local condition="$1"
    local timeout="$2"
    while true; do
        if eval "${condition}"; then
            break
        fi
        sleep ${timeout};
    done
}

# Does not append a new line
function cove_print() {
    { printf "$*" 1>&7 || true ; } 2>>/dev/$DISPENSABLE_OUTPUT_DEV
}

function cove_print_done() {
    cove_print "${GREEN}Done!${NC}\n"
}

function cove_print_error() {
    cove_print "${RED}Error!${NC}\n"
}

function cove_ask() {
    local message="${1}"
    local default_value="${2}"
    while true; do
        read -p "${message} (y/n) [${default_value}]: " value 0<&6 1>&7 2>&8
        value=${value:-$default_value}
        case "$value" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                 UserOutput "Invalid input. Please answer y/n."
                ;;
        esac
    done
}

function cove_get_status() {
    "${COVE_CLIENT_TOOL}" control.status.get
}

function cove_download_bm_installer() {
    if [ -z "${COVE_INSTALLER_URL}" ]; then
        UserOutput ""
        UserOutput "Please provide the URL to download the Backup Manager installer:"
        read -p "URL: " COVE_INSTALLER_URL 0<&6 1>&7 2>&8
    fi

    UserOutput ""
    cove_print "Downloading Backup Manager installer... "
    if command -v curl 2>&1 >/dev/null; then
        curl -fsSL "${COVE_INSTALLER_URL}" -o "${COVE_INSTALLER_PATH}" \
            && cove_print_done || { cove_print_error; return 1; }
    else
        wget -q "${COVE_INSTALLER_URL}" -O "${COVE_INSTALLER_PATH}" \
            && cove_print_done || { cove_print_error; return 1; }
    fi
}

function cove_install_bm() {
    if [ -z "${COVE_INSTALLATION_TOKEN}" ]; then
        UserOutput ""
        UserOutput "Please provide the required installation token:"
        [ -z "${COVE_INSTALLATION_TOKEN}" ] \
            && read -p "Installation token: " COVE_INSTALLATION_TOKEN 0<&6 1>&7 2>&8
    fi

    local installer_new="cove#v1#${COVE_INSTALLATION_TOKEN}#.run"
    local new_install_path="$(dirname ${COVE_INSTALLER_PATH})/${installer_new}"

    # Rename installer
    mv "${COVE_INSTALLER_PATH}" "${new_install_path}"
    COVE_INSTALLER_PATH="${new_install_path}"

    [ ! -x "${COVE_INSTALLER_PATH}" ] && chmod +x "${COVE_INSTALLER_PATH}" || true

    local tmpdir=${TMPDIR:=/tmp}
    local available_space="$(df -kP "${tmpdir}" | awk 'NR==2 {print $4}')"
    if [ "${available_space}" = "0" ]; then
        tmpdir="${COVE_INSTALL_DIR}/temp"
        mkdir -p ${tmpdir} && local rm_tmpfs=1
        mount -t tmpfs -o size=1G tmpfs ${tmpdir} && local unmount_tmpfs=1
    fi

    UserOutput ""
    UserOutput "Installing Backup Manager..."
    TMPDIR="${tmpdir}" "${COVE_INSTALLER_PATH}" 0<&6 1>&7 2>&8
    local retcode=$?

    [ "${unmount_tmpfs}" = "1" ] && umount ${tmpdir} || true
    [ "${rm_tmpfs}" = "1" ] && rm -rf ${tmpdir} || true

    return $retcode
}

# Print the welcome message
UserOutput "
The System is now ready for restore. The Backup Manager installer will be
downloaded and run automatically. If any required parameters have not been
provided, you will be prompted to enter them."

# Get required installation parameters from boot options
read -r cmdline </proc/cmdline
for option in $cmdline; do
    case $option in
        cove_installer=*)
            COVE_INSTALLER_URL="${option#cove_installer=}"
            ;;
        cove_user=*)
            COVE_INSTALLATION_TOKEN="${option#cove_installation_token=}"
            ;;
    esac
done

# Download Backup Manager installer
while true; do
    if cove_download_bm_installer; then
        break
    else
        PrintError "Failed to download the Backup Manager installer."
        if cove_ask "Want to try again?" "y"; then
            cove_ask "Want to change the Backup Manager installer URL?" "y" && COVE_INSTALLER_URL="" || true
            continue
        else
            Error "Failed to download the Backup Manager installer."
        fi
    fi
done

# Install Backup manager installer
while true; do
    if cove_install_bm; then
        break
    else
        PrintError "Failed to install Backup Manager"
        if cove_ask "Want to try again?" "y"; then
            cove_ask "Want to change the installation parameters?" "y" && \
                COVE_INSTALLATION_TOKEN="" || true
            continue
        else
            Error "Failed to install Backup Manager."
        fi
    fi
done

# Wait for the Backup Manager to enter the idle state
cove_print "Waiting for the Backup Manager to enter the idle state... "
cove_wait_for 'local status="$(cove_get_status)"; [ "${status}" = "Idle" ]' 2 && \
    cove_print_done || { cove_print_error; Error "The Backup Manager couldn't enter the idle state."; }

# Initiate the restore
while true; do
    restore_args=(
        control.restore.start
        -datasource FileSystem
        -restore-to $TARGET_FS_ROOT
    )
    if TERM=linux "${COVE_CLIENT_TOOL}" "${restore_args[@]}" 0<&6 1>&7 2>&8; then
        clear 0<&6 1>&7 2>&8
        break
    else
        PrintError "Failed to start the restore."
        cove_ask "Want to try again?" "y" && continue || Error "Failed to start the restore."
    fi
done

# Wait for the restore to be started
cove_print "Waiting for the restore to be started... "
cove_wait_for 'local status="$(cove_get_status)"; [ "${status}" = "Scanning" -o "${status}" = "Restore" ]' 2 \
    && cove_print_done || { cove_print_error; Error "The restore has not started."; }

# Wait for the restore to be finished
cove_print "Waiting for the restore to be finished... "
cove_wait_for 'local status="$(cove_get_status)"; [ "${status}" = "Idle" ]' 15 \
    && cove_print_done || { cove_print_error; Error "The restore has not finished."; }

# Set up ReadOnlyMode for the Backup Manager after the restore
cat <<EOF >> "${TARGET_FS_ROOT}/${COVE_INSTALL_DIR}/etc/config.ini"
[General]
ReadOnlyMode=1
EOF
