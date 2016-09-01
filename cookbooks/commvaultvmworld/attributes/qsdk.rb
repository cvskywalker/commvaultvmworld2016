# QSDK Params
#
# admin / C0mmvault!
#
default['commvaultvmworld']['qsdk']['user'] = "admin"
default['commvaultvmworld']['qsdk']['encpass'] = "311cf8552617f7de75915a1578208c763b9c5e4200250809e"
default['commvaultvmworld']['qsdk']['commserve_clientname'] = "vmw-v11-cs"
default['commvaultvmworld']['qsdk']['commserve_hostname'] = "vmw-v11-cs"

# fixed method access to node attributes (node.foo.bar) as its deprecated and will be removed in Chef 13
if node['commvaultvmworld']['qsdk']['commserve_clientname'].length == 0
	default['commvaultvmworld']['decoupled_install'] = "1"
else
	default['commvaultvmworld']['decoupled_install'] = "0"
end