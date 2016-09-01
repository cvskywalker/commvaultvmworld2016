#
# build local
# Details specific to building when packages are accessible via a CIFS/SMB path local to our soon-to-be provisioned hosts
default['commvaultvmworld']['buildlocal']['path'] = "\\\\10.10.10.3\\VMworld-2016-Packages"
# todo: surely there's a smarter way to do this
default['commvaultvmworld']['buildlocal']['unixpath'] = "//10.10.10.3/VMworld-2016-Packages"
default['commvaultvmworld']['buildlocal']['CS_folder'] = "v11CS"
default['commvaultvmworld']['buildlocal']['FS_MA_VSA_folder'] = "v11FSVSAMA"
default['commvaultvmworld']['buildlocal']['Linux_x8664_folder'] = "v11Linux_x8664"

#
# vagrant
# Details specific to building when compressed packages are accessible via vagrant share
default['commvaultvmworld']['buildvagrant']['path'] = "C:\\Packages"
default['commvaultvmworld']['buildvagrant']['unixpath'] = "/packages"
default['commvaultvmworld']['buildvagrant']['FS_MA_VSA'] = "CVLT_V11_FS_VSA_MAONLY_WinX64.zip"
default['commvaultvmworld']['buildvagrant']['CS'] = "CVLT_V11_COMMSERVE_AND_SELECTPKGS_WinX64.zip"
default['commvaultvmworld']['buildvagrant']['Linux_x8664'] = "CVLT_V11_LINUX_X8664.tar"

#
# s3
# Details specific to buildilng when compressed packages have been uploaded into a S3 bucket
default['commvaultvmworld']['buildbucket']['bucket'] = "pm-buildpacker-build"
default['commvaultvmworld']['buildbucket']['FS_MA_VSA'] = "CVLT_V11_FS_VSA_MAONLY_WinX64.zip"
default['commvaultvmworld']['buildbucket']['CS'] = "CVLT_V11_COMMSERVE_AND_SELECTPKGS_WinX64.zip"
default['commvaultvmworld']['buildbucket']['Linux_x8664'] = "CVLT_V11_LINUX_X8664.tar"
