# Deployment Management Scripts for Kubernetes Resources of a clustered deployment of WSO2 IoT Server

Deployment management scripts for core Kubernetes resources of a clustered deployment of WSO2 IoT Server.

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (compatible with v1.10)
in order to run the steps provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).<br><br>

* A pre-configured Network File System (NFS) to be used as the persistent volume for artifact sharing and persistence.
In the NFS server instance, create a Linux system user account named `wso2carbon` with user id `802` and a system group named `wso2` with group id `802`.
Add the `wso2carbon` user to the group `wso2`.

```
groupadd --system -g 802 wso2
useradd --system -g 802 -u 802 wso2carbon
```

## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-iot`](https://github.com/wso2/kubernetes-iot/)
Git repository.<br>

##### 1. Clone the Kubernetes Resources for WSO2 IoT Server Git repository.

```
git clone https://github.com/wso2/kubernetes-iot.git
```

##### 2. Deploy Kubernetes Ingress controller.

The Kubernetes Ingress resources of this Kubernetes deployment use the NGINX Ingress Controller..

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

##### 3. Setup a Network File System (NFS) to be used for persistent storage.

Create and export unique directories within the NFS server instance for each Kubernetes Persistent Volume resource defined in the
`<KUBERNETES_HOME>/volumes/persistent-volumes.yaml` file.

Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

```
sudo chown -R wso2carbon:wso2 <directory_name>
```

Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

```
chmod -R 700 <directory_name>
```

Update each Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported, NFS server directory path (`NFS_LOCATION_PATH`).

##### 4. Setup product database(s).

For **evaluation purposes**,

* You can use Kubernetes resources provided in the directory `<KUBERNETES_HOME>/extras/rdbms/mysql`
for deploying the product databases, using MySQL in Kubernetes. However, this approach of product database deployment is
**not recommended** for a production setup.

* For using these Kubernetes resources,

  Here, a Network File System (NFS) is needed to be used for persisting MySQL DB data.    
  
  Create and export a directory within the NFS server instance.
        
  Provide read-write-execute permissions to other users for the created folder.
        
  Update the Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported,
  NFS server directory path (`NFS_LOCATION_PATH`) in `<KUBERNETES_HOME>/extras/rdbms/volumes/persistent-volumes.yaml`.
    
In a **production grade setup**,

* Setup the external product databases. Please refer to WSO2 IoT Server's [official documentation](https://docs.wso2.com/display/IOTS331/Setting+Up+the+Databases+for+Clustering)
  on creating the required databases for the deployment.
  
  Provide appropriate connection URLs, corresponding to the created external databases and the relevant driver class names for the data sources defined in
  the following files:
  
  * `<KUBERNETES_HOME>/confs/manager/conf/datasources/android-datasources.xml`
  * `<KUBERNETES_HOME>/confs/manager/conf/datasources/cdm-datasources.xml`
  * `<KUBERNETES_HOME>/confs/manager/conf/datasources/master-datasources.xml`
  * `<KUBERNETES_HOME>/confs/worker/conf/datasources/android-datasources.xml`
  * `<KUBERNETES_HOME>/confs/worker/conf/datasources/cdm-datasources.xml`
  * `<KUBERNETES_HOME>/confs/worker/conf/datasources/master-datasources.xml`
  
  Please refer WSO2's [official documentation](https://docs.wso2.com/display/ADMIN44x/Configuring+master-datasources.xml) on configuring data sources.
 
##### 5. Deploy Kubernetes resources.

Change directory to `<KUBERNETES_HOME>/scripts` and execute the `deploy.sh` shell script on the terminal, with the appropriate configurations as follows:

```
./deploy.sh
```

>To un-deploy, be on the same directory and execute the `undeploy.sh` shell script on the terminal.

##### 7. Access Management Consoles.

Default deployment will expose `altus.apim.com`, `altus.gateway.com`, `altus.internal.gateway.com` and `apim.dev.mycompany.com` hosts.

To access the console in the environment,

a. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses.

  ```
  kubectl get ing
  ```

e.g.

```
NAME                                             HOSTS                       ADDRESS         PORTS     AGE
wso2apim-external-gateway-ingress                altus.gateway.com           <EXTERNAL-IP>   80, 443   7m
wso2apim-ingress                                 altus.apim.com              <EXTERNAL-IP>   80, 443   7m
wso2apim-internal-gateway-ingress                altus.internal.gateway.com  <EXTERNAL-IP>   80, 443   7m
wso2apim-is-as-km-ingress                        apim.dev.mycompany.com      <EXTERNAL-IP>   80, 443   7m
```

b. Add the above host as an entry in /etc/hosts file as follows:

  ```
  <EXTERNAL-IP>	altus.gateway.com
  <EXTERNAL-IP>	altus.apim.com
  <EXTERNAL-IP>	apim.dev.mycompany.com
  ```

c. Try navigating to management consoles from your favorite browser.

- WSO2 API Manager Management Console: `https://altus.apim.com/carbon`

- WSO2 API Manager Publisher: `https://altus.apim.com/publisher`

- WSO2 API Manager Store: `https://altus.apim.com/store`
