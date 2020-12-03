#!/usr/bin/sh

# env
GOOGLE_APPLICATION_CREDENTIALS="/tmp/sa1-294.json" #!!!!!!!!!!! MANDATORY

# requisites
GCLOUD_PROJECT_NAME=$(cat $GOOGLE_APPLICATION_CREDENTIALS | grep project_id | cut -d\" -f 4)
CHALLENGE2_WORKDIR=$(pwd)
GCLOUD_BIN=$(which gcloud)
PYTHON3_BIN=$(which python3)
PIP_BIN=$(which pip)

# necessary
GCLOUD_ZONE="us-east1-b"

# output
output() {
  echo "Settings : "
  echo " CHALLENGE2_WORKDIR = $CHALLENGE2_WORKDIR"
  echo " GOOGLE_APPLICATION_CREDENTIALS = $GOOGLE_APPLICATION_CREDENTIALS"
  echo " GCLOUD_BIN = $GCLOUD_BIN"
  echo " GCLOUD_ZONE = $GCLOUD_ZONE"
  echo " GCLOUD_PROJECT_NAME = $GCLOUD_PROJECT_NAME"
}

# help
help() {
  echo "help ..."
  echo " Define variables:"
  echo " * GOOGLE_APPLICATION_CREDENTIALS = </tmp/auth.json>"
  echo " Connect to:"
  echo " * http://<EXTERNAL_IP>:8080"
  echo " External IP:"
  echo " - gcloud compute instances describe <VM_NAME> --zone <VM_ZONE> --format='get(networkInterfaces[0].accessConfigs[0].natIP)'"
  echo " Python3.*"
  echo " pip modules apache-libcloud pycrypto ansible"
}

# 
create_instance_gcloud() {
  echo "create_instance ..."

  cd $CHALLENGE2_WORKDIR
  
  #python3 env
  $PYTHON3_BIN -m venv .
  source bin/activate
  pip install apache-libcloud pycrypto ansible
 
  #roles
  ansible-galaxy role install -r requirements. yml 
}

# check 
init() {

  # test google_applicatiion_credentials
  test -e "$GOOGLE_APPLICATION_CREDENTIALS" || { echo "$GOOGLE_APPLICATION_CREDENTIALS" not existing;
    help
    exit 0;
  }
  test -e "$GCLOUD_BIN" || { echo gcloud is not installed;
    help
    exit 0;
  }

  # python3 && pip
  [ $($PYTHON3_BIN --version | grep "Python 3.*" | wc -l) -eq "1" ] || { echo python3 is not installed;
    help
    exit 0;
  }
  [ $($PIP_BIN --version | grep "python 3.*" | wc -l) -eq "1" ] || { echo pip is not installed;
    help
    exit 0;
  }

  echo "Environment ... "
  output

  # basic authentication and set projecdt
  $GCLOUD_BIN auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
  $GCLOUD_BIN config set project $GCLOUD_PROJECT_NAME 
  echo Y | $GCLOUD_BIN services enable cloudresourcemanager.googleapis.com
  echo Y | $GCLOUD_BIN services enable cloudbuild.googleapis.com
}

# destroy
destroy() {
  init
  
  #echo Y | $KUBECTL_BIN delete -f $CHALLENGE1_WORKDIR/api/deployment.yaml # deployment 
  #echo Y | $GCLOUD_BIN container clusters delete $GCLOUD_CLUSTER_NAME --zone $GCLOUD_ZONE # cluster
  #echo Y | $GCLOUD_BIN container images delete $GCLOUD_IMAGE_NAME:$GCLOUD_IMAGE_TAG # gcloud image
}

# create
create() {
  init
  create_instance_gcloud # with gcloud
}

case "$1" in
  "destroy" ) echo "call destroy ..." && destroy
	  ;;
  "create" ) echo "call create ..." && create
	  ;;
  "output" ) echo "call output ..." && output
	  ;;
  *) echo "exit" && help 
esac
