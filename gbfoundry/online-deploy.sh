#!/bin/sh

HOST_ARCHITECTURE='amd64'  # amd64、arm64
DISK_RULE='dir' # dir、ssd



#--------------------Do not modify the code below this line if you don't know how it work!----------------
#--------------------Do not modify the code below this line if you don't know how it work!----------------
#--------------------Do not modify the code below this line if you don't know how it work!----------------

WORK_DIR="/data"
PROJECT="gbfoundry"

function print_usage() {
  echo ""
  echo "usage: sh ./online-deploy.sh [COMMAND]"
  echo ""
  echo ""
  echo "  COMMAND:"
  echo "      prepare                 prepare dev tools"
  echo "      infra                   install k8s and tools"
  echo "      product                 deploy charts"
  echo ""
  echo "----------------------------------------------------------------"
  echo "      conn-tidb               connect to tidb"
  echo "      reset-k8s               reset k8s cluster"
  echo ""
  echo ""
}

COUNTDOWN_SECS=10
function countdown() {
  echo -e "\033[0;31m HOST_ARCHITECTURE: $HOST_ARCHITECTURE\033[0m"
  echo -e "\033[0;33m Deployment will start automatically after $COUNTDOWN_SECS seconds, enter 'y' to skip the countdown\033[0m"
  for i in $(seq $COUNTDOWN_SECS -1 1); do
    echo " $i..."
    sleep 1

    # Check for 'y' input and break the loop if found
    if read -t 0.1 -n 1 input && [[ $input == "y" ]]; then
      echo " Countdown skipped"
      break
    fi
  done
}

function confirm_operation() {
  read -p "$1 " answer
  case $answer in
  Y | y)
    echo ""
    ;;
  N | n)
    echo -e "\nNo change.\n"
    exit
    ;;
  *)
    echo -e "\nError choice\n"
    exit
    ;;
  esac
}

function prepare_yum() {
  yum install git ansible wget tmux make -y
}

function prepare_ansible() {
  yum localinstall -y packages/ansible/sshpass-1.06-2.el7.x86_64.rpm
  yum localinstall -y packages/ansible/python-babel-0.9.6-8.el7.noarch.rpm
  yum localinstall -y packages/ansible/python-paramiko-2.1.1-9.el7.noarch.rpm
  yum localinstall -y packages/ansible/python2-jmespath-0.9.4-2.el7.noarch.rpm
  yum localinstall -y packages/ansible/python-markupsafe-0.11-10.el7.x86_64.rpm
  yum localinstall -y packages/ansible/python-jinja2-2.7.2-4.el7.noarch.rpm
  yum localinstall -y packages/ansible/python2-httplib2-0.18.1-3.el7.noarch.rpm
  yum localinstall -y packages/ansible/ansible-2.9.27-1.el7.noarch.rpm
  sed -i 's/^#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg
}

function prepare_config() {
  confPath="${WORK_DIR}/awesome/${PROJECT}/config.yml"
  if [ ! -f $confPath ]; then
    echo -e "\033[31m Can not found $confPath \033[0m"
    exit 1
  fi
  cp $confPath ${WORK_DIR}/awesome/${PROJECT}/gen/config.yml

  pushd ${WORK_DIR}/awesome/${PROJECT}
  ./scripts/online-deploy.sh genconfig
  cp gen/output/env.yaml ./env.yaml
  cp gen/output/group_vars/all.yml /data/awesome/viper/group_vars/all.yml
  cp gen/output/inventory.yaml /data/awesome/viper/inventory

  popd
}

function prepare_deps() {
    ansible-playbook -v  -i inventory  deps.yaml
}

function prepare_all() {
  if [ ! -z ${OPT_PACKAGE} ]; then
    case ${OPT_PACKAGE} in
    yum)
      prepare_yum
      ;;
    ansible)
      prepare_ansible
      ;;
    *)
      print_usage
      exit 1
      ;;
    esac
  else
#    prepare_yum
    prepare_ansible
    prepare_deps
  fi
}

function ansible_infra() {
    bash /data/nova/gbfoundry/scripts/deploy/install_k8s.sh
}

function ansible_product() {
  pushd ${WORK_DIR}/nova/${PROJECT}
    bash scripts/deploy/install_apps.sh
  popd
}

function backup_config() {
  echo -e "\033[0;31m This will clean all services, are you sure? \033[0m[Y/n]"
  confirm_operation "$@"
  mkdir -p /data.bak

  if [ -d /data/awesome/viper ]; then
    cp -f ${WORK_DIR}/awesome/${PROJECT}/gen/config.yml /data.bak/config.yml
    echo "######backup config.yml to /data.bak"
  fi
}

function clean_helm_releases() {
  pushd ${WORK_DIR}/awesome/${PROJECT}
  helmfile destroy
  popd
}

function clean_helm_files() {
  rm -rf /etc/kubernetes/helmfiles/*
  rm -rf /tmp/helmfile* || true

}

function clean_k8s_biz_configs() {
  ns_arr=($(kubectl get ns | grep -v NAME | awk '{print $1}'))
  for d in "${ns_arr[@]}"; do
    if [ "$d" = "default" ]; then
      kubectl delete services -n $d --field-selector metadata.name!=kubernetes
    elif [ ! "$d" = "kube-system" ]; then
      kubectl delete services --all -n $d
    fi
  done
  for d in "${ns_arr[@]}"; do
    echo "###### clean k8s configs in ns: $d ######"
    #kubectl delete pvc --all -n $d
    kubectl -n $d delete secrets password-secrets
    kubectl delete ingress --all -n $d
    kubectl delete jobs --all -n $d
    kubectl delete configmaps license-config -n $d
  done
  #kubectl delete pv --all
}

function clean_k8s() {
  pushd ${WORK_DIR}/awesome/viper
  /usr/bin/ansible-playbook -e confirm=yes clean.yml
  popd
}

function clean_images() {
  img_arr=$(docker images | awk '{ print $3; }')

  for i in "${img_arr[@]}"; do
    if [[ -n "$i" ]]; then
      echo "$i"
      docker rmi $i --force
    fi
  done
}

function clean_disks() {
  if [ $HOST_ARCHITECTURE = "arm64" ]; then
    echo -e "\033[0;31m Arm64 machine not support clean disks now, you should clean disks manually!  \033[0m"
    echo -e "\033[0;31m Arm64 machine not support clean disks now, you should clean disks manually!  \033[0m"
    echo -e "\033[0;31m Arm64 machine not support clean disks now, you should clean disks manually!  \033[0m"
    return
  fi
  echo -e "\033[0;31m This will clean disk partitions, can't recover, are you sure? \033[0m[Y/n]"
  confirm_operation "$@"

  if [ -d /data/awesome/sensecylon ]; then
    mkdir -p /usr/local/infra/ansible
    \cp -a /data/awesome/sensecylon/scripts/clean/clean_disks.sh /usr/local/infra/ansible/clean_disks.sh
    \cp -a /data/awesome/sensecylon/scripts/clean/clean_disks.yaml /usr/local/infra/ansible/clean_disks.yaml
  fi

  if [ -d /data/awesome/viper ]; then
    pushd ${WORK_DIR}/awesome/viper
    /usr/bin/ansible-playbook /usr/local/infra/ansible/clean_disks.yaml
    popd
  fi

}

function conn_tidb() {
  if [ -f /data/awesome/sensecylon/scripts/utils/conn_tidb.sh ]; then
    mkdir -p /usr/local/infra/ansible
    \cp -a /data/awesome/sensecylon/scripts/utils/conn_tidb.sh /usr/local/infra/ansible/conn_tidb.sh
  fi

  sh /usr/local/infra/ansible/conn_tidb.sh
}

function reset_k8s() {
    bash /data/nova/gbfoundry/scripts/deploy/reset_k8s.sh
    ansible-playbook -v  -i /data/nova/gbfoundry/inventory /data/nova/gbfoundry/reset.yaml
}

function main() {
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in

    \
      prepare)
      ACTION="prepare"
      shift
      ;;


    \
      infra)
      ACTION="infra"
      shift
      ;;


    \
      product)
      ACTION="product"
      shift
      ;;

    \
      genconfig)
      ACTION="genconfig"
      shift
      ;;

    \
      clean)
      ACTION="clean"
      shift
      ;;

    clean-disks)
      ACTION="clean-disks"
      shift
      ;;

    \
      genlic)
      ACTION="genlic"
      shift
      ;;

    \
      download)
      ACTION="download"
      shift
      ;;

    conn-tidb)
      ACTION="conn-tidb"
      shift
      ;;

    reset-k8s)
      ACTION="reset-k8s"
      shift
      ;;

    --package | -p)
      OPT_PACKAGE="$2"
      shift
      shift
      ;;

    \
      \
      \
      *)
      print_usage
      exit 1
      ;;
    esac
  done

  if [ "${ACTION}" == "prepare" ]; then
    countdown
    prepare_all
  elif [ "$ACTION" == "infra" ]; then
    countdown
    ansible_infra
  elif [ "$ACTION" == "product" ]; then
    ansible_product
  elif [ "$ACTION" == "genconfig" ]; then
    prepare_config
  elif [ "$ACTION" == "conn-tidb" ]; then
    conn_tidb
  elif [ "$ACTION" == "reset-k8s" ]; then
    reset_k8s
  elif [ "$ACTION" == "reload" ]; then
    reload_biz
  elif [ "$ACTION" == "clean" ]; then
    backup_config
    clean_helm_releases
    clean_helm_files
    clean_k8s_biz_configs
    #    clean_k8s
    #clean_images
    clean_disks
  elif [ "$ACTION" == "clean-disks" ]; then
    clean_disks
  else
    print_usage
    exit 1
  fi
}

main "$@"
