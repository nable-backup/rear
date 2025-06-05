# systemstate-workflow.sh
#
# systemstate workflow for Relax-and-Recover
#
# This file is part of Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

WORKFLOW_systemstate_DESCRIPTION="save only system state configuration"
WORKFLOWS+=( systemstate )
WORKFLOW_systemstate () {
    #SourceStage "prep"
    Source $SHARE_DIR/prep/default/005_remove_workflow_conf.sh
    Source $SHARE_DIR/prep/default/100_init_workflow_conf.sh
    Source $SHARE_DIR/prep/GNU/Linux/210_include_dhclient.sh
    Source $SHARE_DIR/prep/GNU/Linux/310_include_cap_utils.sh
    Source $SHARE_DIR/prep/default/320_include_uefi_env.sh
    Source $SHARE_DIR/prep/default/400_save_directories.sh
    Source $SHARE_DIR/prep/default/490_store_write_protect_settings.sh

    #SourceStage "layout/save"
    Source $SHARE_DIR/layout/save/GNU/Linux/100_create_layout_file.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/150_save_diskbyid_mappings.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/190_opaldisk_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/200_partition_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/210_raid_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/220_lvm_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/230_filesystem_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/240_swaps_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/250_drbd_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/260_crypt_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/270_hpraid_layout.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/280_multipath_layout.sh
    Source $SHARE_DIR/layout/save/default/300_list_dependencies.sh
    Source $SHARE_DIR/layout/save/default/310_autoexclude_usb.sh
    Source $SHARE_DIR/layout/save/default/310_include_exclude.sh
    Source $SHARE_DIR/layout/save/default/320_autoexclude.sh
    Source $SHARE_DIR/layout/save/default/330_remove_exclusions.sh
    Source $SHARE_DIR/layout/save/default/335_remove_excluded_multipath_vgs.sh
    Source $SHARE_DIR/layout/save/default/340_generate_mountpoint_device.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/350_copy_drbdtab.sh
    Source $SHARE_DIR/layout/save/default/445_guess_bootloader.sh
    Source $SHARE_DIR/layout/save/default/450_check_bootloader_files.sh
    Source $SHARE_DIR/layout/save/default/450_check_network_files.sh
    Source $SHARE_DIR/layout/save/default/490_check_files_to_patch.sh
    Source $SHARE_DIR/layout/save/GNU/Linux/510_current_disk_usage.sh
    Source $SHARE_DIR/layout/save/default/600_snapshot_files.sh
    Source $SHARE_DIR/layout/save/default/950_verify_disklayout_file.sh

    #SourceStage "rescue"
    Source $SHARE_DIR/rescue/default/010_merge_skeletons.sh
    Source $SHARE_DIR/rescue/default/020_create_skeleton_dirs.sh
    Source $SHARE_DIR/rescue/GNU/Linux/220_load_modules_from_initrd.sh
    Source $SHARE_DIR/rescue/GNU/Linux/230_storage_and_network_modules.sh
    Source $SHARE_DIR/rescue/GNU/Linux/240_kernel_modules.sh
    Source $SHARE_DIR/rescue/GNU/Linux/260_collect_initrd_modules.sh
    Source $SHARE_DIR/rescue/GNU/Linux/260_storage_drivers.sh
    Source $SHARE_DIR/rescue/GNU/Linux/320_inet6.sh
    Source $SHARE_DIR/rescue/COVE/default/600_store_cove_vars.sh
    Source $SHARE_DIR/rescue/default/850_save_sysfs_uefi_vars.sh
    Source $SHARE_DIR/rescue/GNU/Linux/990_sysreqs.sh

    #SourceStage "build"
    Source $SHARE_DIR/build/GNU/Linux/100_copy_as_is.sh
    Source $SHARE_DIR/build/GNU/Linux/400_copy_modules.sh
    Source $SHARE_DIR/build/default/975_update_os_conf.sh

    # making archive with artifacts
    Source $SHARE_DIR/output/SYSTEMSTATE/default/450_create_systemstate_archive.sh
}
