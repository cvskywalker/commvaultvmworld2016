#
#
# Temporary XML filenames to use on guest
default['commvaultvmworld']['xml']['csinstall'] = "cs_silent_install.tmp.xml"
default['commvaultvmworld']['xml']['csstoragelibrary'] = "cs_create_storage_library.xml"
default['commvaultvmworld']['xml']['csstoragepolicy'] = "cs_create_storage_policy.xml"
default['commvaultvmworld']['xml']['win_fs_install'] = "fs_win_silent_install.tmp.xml"
default['commvaultvmworld']['xml']['linux_fs_install'] = "fs_linux_silent_install.tmp.xml"
default['commvaultvmworld']['xml']['win_fsmavsa_install'] = "fsmavsa_win_silent_install.tmp.xml"
default['commvaultvmworld']['xml']['linux_fsmavsa_install'] = "fsmavsa_linux_silent_install.tmp.xml"

# Agent configuration XML
default['commvaultvmworld']['xml']['configure_filesystem_baseline'] = "configure_filesystem_baseline.tmp.xml"
default['commvaultvmworld']['xml']['backup_filesystem_baseline'] = "backup_filesystem_baseline.tmp.xml"
default['commvaultvmworld']['fsconfig']['content'] = "/etc/hosts"

# FREL Conversion components
default['commvaultvmworld']['xml']['frelconversion_properties'] = "frelconversion_properties"
default['commvaultvmworld']['xml']['frelconversion_directory'] = "/opt/commvault/3Dfs"

# NFS-Ganesha
default['commvaultvmworld']['xml']['enable_3dfs'] = "enable_3dfs.xml"

# Example2 Restore
default['commvaultvmworld']['xml']['restore_filesystem'] = "restore_filesystem.tmp.xml"