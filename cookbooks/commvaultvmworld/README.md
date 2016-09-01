# commvaultvmworld

Chef Cookbook for deploying VMworld 2016 CVLT demo

Issues:

1. CS Hostname hardcoded because version of chef in image (12.8.1) won't play nice with compat_provider, so can't dynamically inject it

Todos:

1. Hardcoded path assumption for install path INSIDE the tarball/packages uploaded to S3
2. Need chocolatey local cache for no-internet scenario (VMworld backup plan)