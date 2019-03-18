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

## create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
#${KUBECTL} create -f ../../rbac/rbac.yaml
#
#echoBold 'Creating Kubernetes ConfigMaps...'
#${KUBECTL} create configmap integrator-conf --from-file=../confs/
#${KUBECTL} create configmap integrator-conf-axis2 --from-file=../confs/axis2/
#${KUBECTL} create configmap integrator-conf-datasources --from-file=../confs/datasources/

# create MySQL initialization script ConfigMap
${KUBECTL} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

#echoBold 'Creating Kubernetes Services...'
#${KUBECTL} create -f ../integrator-service.yaml
#${KUBECTL} create -f ../integrator-gateway-service.yaml
#
#echoBold 'Creating Kubernetes Ingresses...'
#${KUBECTL} create -f ../ingresses/integrator-gateway-ingress.yaml
#${KUBECTL} create -f ../ingresses/integrator-ingress.yaml

echoBold 'Deploying Kubernetes Persistent Volumes...'
#${KUBECTL} create -f ../volumes/persistent-volumes.yaml
${KUBECTL} create -f ../extras/rdbms/volumes/persistent-volumes.yaml

# MySQL
echoBold 'Deploying the databases...'
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-service.yaml
sleep 30s

#echoBold 'Creating the Kubernetes Deployment...'
#${KUBECTL} create -f ../integrator-volume-claim.yaml
#${KUBECTL} create -f ../integrator-deployment.yaml

echoBold 'Finished'
