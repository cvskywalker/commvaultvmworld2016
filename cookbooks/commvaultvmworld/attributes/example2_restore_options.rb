#
# Restore options for Example 2

default['commvaultvmworld']['restore']['backupsetName'] = "defaultBackupSet"
default['commvaultvmworld']['restore']['original_client'] = "production"
default['commvaultvmworld']['restore']['original_path'] = "/usr/share/nginx/html"
default['commvaultvmworld']['restore']['destination_client'] = Chef::Config[:node_name]

# If you set inPlace, you don't need to specify destination_path
default['commvaultvmworld']['restore']['inPlace'] = "true"
default['commvaultvmworld']['restore']['destination_path'] = ""

default['commvaultvmworld']['restore']['overwriteFiles'] = "true"