# Kubernetes Resources for a clustered deployment of WSO2 IoT Server

Core Kubernetes resources for a [clustered deployment of WSO2 IoT Server](https://docs.wso2.com/display/IOTS331/Clustering+WSO2+IoT+Server).

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

##### 2. Create a namespace named `wso2` and a service account named `wso2svc-account`, within the namespace `wso2`.

```
kubectl create namespace wso2
kubectl create serviceaccount wso2svc-account -n wso2
```

Then, switch the context to new `wso2` namespace.

```
kubectl config set-context $(kubectl config current-context) --namespace=wso2
```

##### 3. Setup product database(s).

Setup the external product databases. Please refer to WSO2 IoT Server's [official documentation](https://docs.wso2.com/display/IOTS331/Setting+Up+the+Databases+for+Clustering)
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

**Note**:

* For **evaluation purposes**, you can use Kubernetes resources provided in the directory<br>
`<KUBERNETES_HOME>/extras/rdbms/mysql` for deploying the product databases, using MySQL in Kubernetes. However, this approach of product database deployment is
**not recommended** for a production setup.

* For using these Kubernetes resources,

    first create a Kubernetes ConfigMap for passing database script(s) to the deployment.
    
    ```
    kubectl create configmap mysql-dbscripts --from-file=<KUBERNETES_HOME>/extras/confs/mysql/dbscripts/
    ```
    
    Here, a Network File System (NFS) is needed to be used for persisting MySQL DB data.
    
    Create and export a directory within the NFS server instance.
    
    Provide read-write-execute permissions to other users for the created folder.
    
    Update the Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported,
    NFS server directory path (`NFS_LOCATION_PATH`) in `<KUBERNETES_HOME>/extras/rdbms/volumes/persistent-volumes.yaml`.
    
    Deploy the persistent volume resource and volume claim as follows:
    
    ```
    kubectl create -f <KUBERNETES_HOME>/extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
    kubectl create -f <KUBERNETES_HOME>/extras/rdbms/volumes/persistent-volumes.yaml
    ```

    Then, create a Kubernetes service (accessible only within the Kubernetes cluster), followed by the MySQL Kubernetes deployment, as follows:
    
    ```
    kubectl create -f <KUBERNETES_HOME>/extras/rdbms/mysql/mysql-service.yaml
    kubectl create -f <KUBERNETES_HOME>/extras/rdbms/mysql/mysql-deployment.yaml
    ```

##### 4. Setup a Network File System (NFS) to be used for persistent storage.

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

Then, deploy the persistent volume resource and volume claim as follows:

```
kubectl create -f <KUBERNETES_HOME>/iot/wso2iot-volume-claim.yaml
kubectl create -f <KUBERNETES_HOME>/volumes/persistent-volumes.yaml
```
    
##### 5. Create Kubernetes ConfigMaps for passing WSO2 product configurations into the Kubernetes cluster.

```

kubectl create configmap iot-manager-conf --from-file=confs/manager/conf/
kubectl create configmap iot-manager-conf-datasources --from-file=confs/manager/conf/datasources/
kubectl create configmap iot-manager-conf-etc --from-file=confs/manager/conf/etc/
kubectl create configmap iot-manager-conf-identity --from-file=confs/manager/conf/identity/
kubectl create configmap iot-manager-conf-api-store --from-file=confs/manager/repository/deployment/server/jaggeryapps/api-store/site/conf/
kubectl create configmap iot-manager-conf-devicemgt --from-file=confs/manager/repository/deployment/server/jaggeryapps/devicemgt/app/conf/
kubectl create configmap iot-manager-conf-portal --from-file=confs/manager/repository/deployment/server/jaggeryapps/portal/configs/
kubectl create configmap iot-manager-conf-publisher --from-file=confs/manager/repository/deployment/server/jaggeryapps/publisher/config/
kubectl create configmap iot-manager-conf-store --from-file=confs/manager/repository/deployment/server/jaggeryapps/store/config/

kubectl create configmap iot-worker-conf --from-file=confs/worker/conf/
kubectl create configmap iot-worker-conf-datasources --from-file=confs/worker/conf/datasources/
kubectl create configmap iot-worker-conf-etc --from-file=confs/worker/conf/etc/
kubectl create configmap iot-worker-conf-identity --from-file=confs/worker/conf/identity/
kubectl create configmap iot-worker-conf-devicetypes --from-file=confs/worker/repository/deployment/server/devicetypes/
kubectl create configmap iot-worker-conf-api-store --from-file=confs/worker/repository/deployment/server/jaggeryapps/api-store/site/conf/
kubectl create configmap iot-worker-conf-devicemgt --from-file=confs/worker/repository/deployment/server/jaggeryapps/devicemgt/app/conf/
kubectl create configmap iot-worker-conf-portal --from-file=confs/worker/repository/deployment/server/jaggeryapps/portal/configs/
kubectl create configmap iot-worker-conf-publisher --from-file=confs/worker/repository/deployment/server/jaggeryapps/publisher/config/
kubectl create configmap iot-worker-conf-store --from-file=confs/worker/repository/deployment/server/jaggeryapps/store/config/

```

##### 8. Create Kubernetes Services and Deployments for WSO2 IoT Server.

```
kubectl create -f <KUBERNETES_HOME>/iot/manager/wso2iot-manager-deployment.yaml
kubectl create -f <KUBERNETES_HOME>/iot/worker/wso2iot-worker-deployment.yaml
kubectl create -f <KUBERNETES_HOME>/iot/wso2iot-service.yaml
```

##### 9. Deploy Kubernetes Ingress resources.

The WSO2 IoT Server Kubernetes Ingress resources use the NGINX Ingress Controller.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

Finally, deploy the WSO2 IoT Server Kubernetes Ingress resources as follows:

```
kubectl create -f <KUBERNETES_HOME>/ingresses/wso2iot-gateway-ingress.yaml
kubectl create -f <KUBERNETES_HOME>/ingresses/wso2iot-ingress.yaml
```

##### 10. Access Management Consoles.

Default deployment will expose `wso2apim` and `wso2apim-gateway hosts.

To access the console in the environment,

a. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses.

  ```
  kubectl get ing
  ```

e.g.

```
NAME                                             HOSTS                       ADDRESS         PORTS     AGE
wso2apim-with-analytics-apim-ingress             wso2apim,wso2apim-gateway   <EXTERNAL-IP>   80, 443   7m
```

b. Add the above host as an entry in /etc/hosts file as follows:

  ```
  <EXTERNAL-IP>	wso2apim
  <EXTERNAL-IP>	wso2apim-gateway
  ```

c. Try navigating to `https://wso2apim/carbon` from your favorite browser.

##### 11. Scale up using `kubectl scale`.

Default deployment runs a single replica (or pod) of WSO2 API Manager. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/pattern-1/apim/wso2apim-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
