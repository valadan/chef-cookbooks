Vagrant Chef Oracle Project
---------------------------

Vagrant Project to create an 64-bit Ubuntu Server-based Oracle/Java Development VM with all applications other than an IDE, to build and test Java EE projects.

<h4>Major Components</h4>
* Oracle JDK 1.7.0_45-b18 64-bit and all alternatives
* Oracle-related Environment variables
* WebLogic Server 12.1.2
* (1) WLS domain / (1) WLS managed server
* Oracle Database Express Edition 11g Release 2 (11.2) for Linux x86-64 (TBD)

<h4>Recipes Tested and Working</h4>
<table>
  <tr>
    <th>Recipe</th><th>Description</th>
  </tr>
  <tr>
    <td>install-java</td><td>Installs Oracle JDK 1.7.0_45-b18 and all alternatives</td>
  </tr>
  <tr>
    <td>install-env-vars</td><td>Installs Oracle-related environment variables</td>
  </tr>
  <tr>
    <td>create-swapfile</td><td>Creates 512 MB swapfile for WebLogic Server installer</td>
  </tr>
  <tr>
    <td>install-wls</td><td>Installs Oracle WebLogic Server 12.1.2</td>
  </tr>
  <tr>
    <td>install-wls-domain</td><td>Creates single WLS domain and server</td>
  </tr>
  <tr>
    <td>install-express</td><td>Installs Oracle Database Express Edition (**unfinished**)</td>
  </tr>
</table>

<h4>Required Downloads to 'artifacts' folder within this repo</h4>
* *[jdk-7u45-linux-x64.tar.gz] (http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)*
* *[wls_121200.jar] (http://www.oracle.com/technetwork/middleware/weblogic/downloads/wls-for-dev-1703574.html)*
* *[oracle-xe-11.2.0-1.0.x86_64.rpm.zip] (http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html)*

<h4>Ubuntu Cloud Image Used to Create VM</h4>
* *[Preferred: Ubuntu Server 13.10 (Saucy Salamander) 64-bit daily build] (http://cloud-images.ubuntu.com/vagrant/saucy/current/saucy-server-cloudimg-amd64-vagrant-disk1.box)*
* *[Alternate: Ubuntu Server 12.04 LTS (Precise Pangolin) 64-bit daily build] (http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box)*
