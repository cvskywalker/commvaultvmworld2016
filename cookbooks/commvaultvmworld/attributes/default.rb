# Package storage location
#
# 3x Build Methods
#   - s3 - assume zip files in S3, download & extract & clean-up
#   - vagrantfolder - packages are zipped and mapped via vagrant shared folder
#   - local_path_extracted - assume extracted into local_path

# Select your build method...

# default['commvaultvmworld']['buildmethod'] = "s3"
default['commvaultvmworld']['buildmethod'] = "vagrantfolder"
# default['commvaultvmworld']['buildmethod'] = "local_path_extracted"

#
# Everything else:
#
# build_method_details - specifics around what packages are where, etc. depending upon the 'buildmethod'
# commserve - specifics for configuring the Commserve for VMworld Demo mode
# qsdk - covers components required for talking to Commvault API
# xml - XML templates
#