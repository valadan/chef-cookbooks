## Vagrant Chef Oracle Project

Cookbook recipes to create (2) 64-bit Ubuntu Server-based Oracle/Java Development VMs with all applications other than an IDE, to build and test Java EE projects.

#### Major Components
* Oracle JDK 1.7.0_45-b18 64-bit for Linux x86-64 (apps vm)
* Oracle-related Environment variables (apps vm)
* Oracle WebLogic Server 12c (12.1.2) (apps vm)
* WLS domain and admin server (apps vm)
* Oracle Database Express Edition 11g Release 2 (11.2) for Linux x86-64 (dbs vm)

</br>
#### Recipes Tested and Working
The following recipes are included in the '`dev-setup`' cookbook:


| **Recipe**            | **Description**                                    |
|-----------------------|----------------------------------------------------|
| install-java          | Installs Oracle JDK 1.7.0_45                       |
| install-env-vars      | Installs Oracle-related environment variables      |
| create-swapfile       | Creates swapfile for WebLogic Server installer     |
| install-wls           | Installs Oracle WebLogic Server 12c                |
| install-wls-domain    | Creates one WLS domain and admin server            |
| install-express       | Installs Oracle Database XE 11g                    |
| remove-swapfile       | Removes swapfile used by WebLogic Server installer |

</br>
#### Third-Party Files
The '`dev-setup`' cookbook requires the below files be downloaded to separate '`chef-artifacts`' directory, in same parent folder as this git repo. Since these files are so large, I download them ahead of time and use VirtualBox's synced folder feature to copy them into VM.
* [jdk-7u45-linux-x64.tar.gz](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
* [wls_121200.jar](http://www.oracle.com/technetwork/middleware/weblogic/downloads/wls-for-dev-1703574.html)
* [oracle-xe-11.2.0-1.0.x86_64.rpm.zip](http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html)

</br>
#### Vargrant Box
The '`dev-setup`' cookbook was tested with VMs based on Ubuntu Cloud Images.
* Preferred: [Ubuntu Server 13.10 (Saucy Salamander) 64-bit daily build](http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box)
* Alternate: [Ubuntu Server 12.04 LTS (Precise Pangolin) 64-bit daily build](http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box)
