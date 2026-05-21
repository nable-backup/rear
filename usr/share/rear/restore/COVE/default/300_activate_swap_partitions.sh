# Activate swap partition(s) (if they exist) to extend virtual memory before Backup Manager restore starts

is_true "$COVE_ACTIVATE_SWAP_PARTITIONS" || return 0

local device
local swap_devices=()
while read -r _ device _; do
    swap_devices+=("$device")
done < <( grep "^swap " "$LAYOUT_FILE" )

if [ ${#swap_devices[@]} -eq 0 ]; then
    LogPrint "No swap partitions found in $LAYOUT_FILE, skipping swap activation."
    return 0
fi

# Deactivate any currently active swap. This is needed in case of BMR restart.
if tail -n +2 /proc/swaps 2>/dev/null | grep -q .; then
    LogPrint "Deactivating existing swap before reactivation."
    swapoff -v -a || LogPrintError "Failed to deactivate existing swap. Continuing anyway."
fi

for device in "${swap_devices[@]}"; do
    if [ -b "$device" ]; then
        LogPrint "Activating swap on $device"
        swapon "$device" || LogPrintError "Failed to activate swap on $device"
    else
        LogPrintError "Swap device $device not found or not a block device, skipping."
    fi
done
