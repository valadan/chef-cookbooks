Vagrant Chef Oracle Project
---------------------------

Project to create an Oracle/Java Development VM with all applications other than an IDE, to build and test Java EE projects.

<h4>Major Components</h4>
* Oracle JDK
* Oracle-related Environment variables
* WebLogic Server / domain / managed server
* Oracle Database Express Edition

<h4>Recipes Tested and Working</h4>
<table>
  <tr>
    <th>Recipe</th><th>Description</th>
  </tr>
  <tr>
    <td>install-java</td><td>Installs Oracle JDK 1.7.0_45</td>
  </tr>
  <tr>
    <td>install-env-vars</td><td>Installs Oracle-related environment variables</td>
  </tr>
  <tr>
    <td>create-swapfile</td><td>Creates 512 MB swapfile for WebLogic Server installer</td>
  </tr>
  <tr>
    <td>install-wls</td><td>Installs Oracle Weblogic Server 12.1.2</td>
  </tr>
  <tr>
    <td>install-wls-domain</td><td>Creates single WLS domain and server</td>
  </tr>
</table>

<h4>Required Downloads to 'artifacts'</h4>
* *[jdk-7u45-linux-x64.tar.gz] (http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)*
* *[wls_121200.jar] (http://www.oracle.com/technetwork/middleware/weblogic/downloads/wls-for-dev-1703574.html)*

<h4>Required Ubuntu Cloud Image to 'vagrant-oracle-repo'</h4>
* *[saucy-server-cloudimg-amd64-vagrant-disk1.box] (http://cloud-images.ubuntu.com/vagrant/saucy/)*