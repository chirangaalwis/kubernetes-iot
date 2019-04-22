#!/bin/bash
# ------------------------------------------------------------------------
# Copyright 2019 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

set -e

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

#function usage () {
#    echoBold "This script automates the installation of Kubernetes resources for WSO2 Enterprise Integrator's Integrator profile\n"
#    echoBold "Allowed arguments:\n"
#    echoBold "-h | --help"
#    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
#    echoBold "--wp | --wso2-password\t\tYour WSO2 password\n\n"
#}
#
#WSO2_SUBSCRIPTION_USERNAME=''
#WSO2_SUBSCRIPTION_PASSWORD=''
#
## capture named arguments
#while [ "$1" != "" ]; do
#    PARAM=`echo $1 | awk -F= '{print $1}'`
#    VALUE=`echo $1 | awk -F= '{print $2}'`
#
#    case ${PARAM} in
#        -h | --help)
#            usage
#            exit 1
#            ;;
#        --wu | --wso2-username)
#            WSO2_SUBSCRIPTION_USERNAME=${VALUE}
#            ;;
#        --wp | --wso2-password)
#            WSO2_SUBSCRIPTION_PASSWORD=${VALUE}
#            ;;
#        *)
#            echoBold "ERROR: unknown parameter \"${PARAM}\""
#            usage
#            exit 1
#            ;;
#    esac
#    shift
#done

# create a new Kubernetes Namespace
${KUBECTL} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBECTL} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBECTL} config set-context $(${KUBECTL} config current-context) --namespace=wso2

## create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
#${KUBECTL} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}

echoBold 'Creating Kubernetes ConfigMaps...'
${KUBECTL} create configmap iot-manager-conf --from-file=../confs/manager/conf/
${KUBECTL} create configmap iot-manager-conf-datasources --from-file=../confs/manager/conf/datasources/
${KUBECTL} create configmap iot-manager-conf-etc --from-file=../confs/manager/conf/etc/
${KUBECTL} create configmap iot-manager-conf-identity --from-file=../confs/manager/conf/identity/
${KUBECTL} create configmap iot-manager-conf-api-store --from-file=../confs/manager/repository/deployment/server/jaggeryapps/api-store/site/conf/
${KUBECTL} create configmap iot-manager-conf-devicemgt --from-file=../confs/manager/repository/deployment/server/jaggeryapps/devicemgt/app/conf/
${KUBECTL} create configmap iot-manager-conf-portal --from-file=../confs/manager/repository/deployment/server/jaggeryapps/portal/configs/
${KUBECTL} create configmap iot-manager-conf-publisher --from-file=../confs/manager/repository/deployment/server/jaggeryapps/publisher/config/
${KUBECTL} create configmap iot-manager-conf-store --from-file=../confs/manager/repository/deployment/server/jaggeryapps/store/config/

${KUBECTL} create configmap iot-worker-conf --from-file=../confs/worker/conf/
${KUBECTL} create configmap iot-worker-conf-datasources --from-file=../confs/worker/conf/datasources/
${KUBECTL} create configmap iot-worker-conf-etc --from-file=../confs/worker/conf/etc/
${KUBECTL} create configmap iot-worker-conf-identity --from-file=../confs/worker/conf/identity/
${KUBECTL} create configmap iot-worker-conf-devicetypes --from-file=../confs/worker/repository/deployment/server/devicetypes/
${KUBECTL} create configmap iot-worker-conf-api-store --from-file=../confs/worker/repository/deployment/server/jaggeryapps/api-store/site/conf/
${KUBECTL} create configmap iot-worker-conf-devicemgt --from-file=../confs/worker/repository/deployment/server/jaggeryapps/devicemgt/app/conf/
${KUBECTL} create configmap iot-worker-conf-portal --from-file=../confs/worker/repository/deployment/server/jaggeryapps/portal/configs/
${KUBECTL} create configmap iot-worker-conf-publisher --from-file=../confs/worker/repository/deployment/server/jaggeryapps/publisher/config/
${KUBECTL} create configmap iot-worker-conf-store --from-file=../confs/worker/repository/deployment/server/jaggeryapps/store/config/

# create MySQL initialization script ConfigMap
${KUBECTL} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

echoBold 'Creating Kubernetes Ingresses...'
${KUBECTL} create -f ../ingresses/wso2iot-gateway-ingress.yaml
${KUBECTL} create -f ../ingresses/wso2iot-ingress.yaml

echoBold 'Deploying Kubernetes Persistent Volumes...'
${KUBECTL} create -f ../volumes/persistent-volumes.yaml
${KUBECTL} create -f ../extras/rdbms/volumes/persistent-volumes.yaml

echoBold 'Creating Kubernetes Persistent Volume Claims...'
${KUBECTL} create -f ../iot/wso2iot-volume-claim.yaml

# MySQL
echoBold 'Deploying the databases...'
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-service.yaml
sleep 30s

echoBold 'Creating the Kubernetes Deployment...'
${KUBECTL} create -f ../iot/manager/wso2iot-manager-deployment.yaml
${KUBECTL} create -f ../iot/manager/wso2iot-manager-service.yaml
sleep 120s
${KUBECTL} create -f ../iot/worker/wso2iot-worker-deployment.yaml
${KUBECTL} create -f ../iot/worker/wso2iot-worker-service.yaml
${KUBECTL} create -f ../iot/worker/wso2iot-worker-migration-service.yaml
sleep 240s

echoBold 'Finished'
