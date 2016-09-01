# VMworld 2016 Commvault "Hacking your Backups" code drop

This is the Vagrantfile and Chef cookbook used to present use cases for Commvault's "Hacking your backups: Making your Backups and Data work for you" session at VMworld 2016.

It contains all of the material required to stand this up in your own environment, with exception of the Commvault installation media, or re-use core logic as part of your own Chef recipe development for basic deployment/configuration automation tasks.

## Who is this useful for?

* Commvault backup administrators looking to automate, or work with automation teams on low hanging fruit activities (dev/test, auto-deployment/configuration)
* Commvault admins or application owners looking to understand more about leveraging Commvault's APIs in a build pipeline (production, dev, test, training)


## What do these scripts do?

* **Vagrantfile** - contains self-descriptive code to instruct Vagrant (https://www.vagrantup.com) how to create a test Commvault environment consisting of 1x CommServe, 3x example clients (Ubuntu 14.04 LTS) and 1x MA/FREL for testing NFS access.

* **cookbooks** - contains the "commvaultvmworld" cookbook, "nginx" cookbook (the sample application demo'd throughout the session) and required scripts for Windows deployment (windows, chef_handler, chocolatey).   Will perform the following actions:
** Auto-deploy & configure a v11 CommServe
** Auto-deploy & configure a File System Agent
** Configure File System subclent
** Launch File System backup
** Launch File System restore
** Can also deploy Media Agent, Virtual Server Agent and convert a standard Media Agent to a FREL host


## Will this work on Windows?

**Yes!**  While the demo was conducted on Linux clients for performance, the cookbook supports both Windows and Linux based clients.  The only reason I ran this on Linux was for lightweight system requirements, since it was running from my Mac laptop.

Any platform that Commvault supports, is a platform/agent that can be orchestrated and controlled via the API, and therefore by your desired automation scripts/approach.


## What does this code really do?

The cookbook really performs two crucial features:

* Deploying and configuring Commvault agents (Silent Installation method)
* Demonstrating interacting with the XML API (qlogin, qoperation execute, qlogout)


## What more could this do?

Since we are orchestrating Commvault, any supported platform by Commvault can be configured, and data within protected and restored based upon that agent's supported features.  For example, for SQL you can protect a SQL database, then perform a copy database to a new SQL host & new DB name.

You can also use these scripts to rapidly build a test Commvault environment, handy if you are experimenting/training with Commvault or looking to automate lab re-builds alongside your production environment.

Check the Commvault Books Online for more details on what can be achieved.

http://documentation.commvault.com/commvault/v11/article?p=products/tools/overview.htm


## How do I get started?

1. Download & install Vagrant (https://www.vagrantup.com) and Virtualbox (https://www.virtualbox.org/wiki/Downloads)
2. Download this github repo into a folder of your choice
3. Download Commvault Media - see Media section below
4. Run `vagrant up commserve example1 production`
5. Once backup has completed, run `vagrant up test`

The Commvault username and password for this lab is:

`username: admin
password: C0mmvault!`


## Media

The commvaultvmworld cookbook was originally designed to operate from an AWS-based environment, however given the latency/bandwidth issues with Internet on-site, it will accept installation media via the following 3 methods.

1. `vagrantfolder` - ZIP files containing the Install media on the Host OS.  Cookbook will handle temporary extraction, execution and cleanup from within the Guest OS.
2. `local_path_extracted` - Install media has been extracted to a CIFS/SMB path.  Scripts will execute directly from the CIFS/SMB path.
3. `s3` - ZIP files containing Install media residing within a S3 bucket.  Cookbook will download, extract, execute then cleaup from within the Guest OS.

By default this is set to "vagrantfolder", controlled by the attributes/default.rb file (default['commvaultvmworld']['buildmethod'])

Cookbook also expects the installation media to be seperated into two sets of directories / ZIP files (Full media vs. reduced install media containing just File System / Media Agent / Virtual Server Agent), but in reality you can just have a single zip file / directory and point the cookbook to that as well.   Intent was to reduce the size of the download for the individual clients when operating in cloud (250mb zip file vs. 4.7GB zip file).


## Why isn't this uploaded to Supermarket? / Will you put something into Supermarket/PuppetForge? / What's next?

This cookbook was intended as a barebones demonstration to wrap around XML API calls into Commvault Version 11, and makes no use of LWRP concepts, but we are currently evaluating the requirements for base integration and subsequent publishing into Supermarket, etc. and as part of that effort we would look to ensure it has extendability, uses LWRP concepts, etc.


## Where can I get more info on Commvault's API?

Commvault offers two APIs - REST API and XML API.  Both can be discovered via the following link:

http://documentation.commvault.com/commvault/v11/article?p=products/tools/overview.htm

Both offerings have example JSON & XML listings, showing all possible options.   

Additionally, XML can be taken from the CommCell Console by performing an operation and selecting "Save As Script" instead of submitting the job, which will take your specified job options and provide a pre-generated XML which can be used.


## How can I get in touch?

Feel free to contact me via https://twitter.com/cv_skywalker or lwalker at commvault dot com.


## Legal

This software/code is being provided “as is” without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose or non-infringement. In no event shall Commvault be liable for any damages, claims or other liability in arising out of or in connection with the software or any use thereof.  This software is being provided for demonstration purposes only and may not be used for any other purposes. Commvault undertakes no obligation to support, update, enhance or modify any such software, and no support shall be provided by Commvault.