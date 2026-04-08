# Insert /boot/grub2/grubenv and /boot/grub/grubenv into BACKUP_RESTORE_MOVE_AWAY_FILES

if is_grubenv_set_required; then
    BACKUP_RESTORE_MOVE_AWAY_FILES+=( /boot/grub2/grubenv /boot/grub/grubenv )
fi
