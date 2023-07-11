FILE_DIR="../099-files"
HOST_ARCH="amd64"

PLUGIN_DIR="$HOME/.local/share/helm/plugins"

. ../098-utils/echo_color.sh

function install_binary() {
  tool=$1
  version=$2
  sudo rm -rf /usr/local/bin/$tool

  sudo cp -a ${FILE_DIR}/$tool-$version-$HOST_ARCH /usr/local/bin/${tool}
  sudo chmod +x /usr/local/bin/${tool}
  echo_green "***** $tool installed ******"
}

function install_helm_plugin() {
  tool=$1
  version=$2
  rm -rf $PLUGIN_DIR/$tool

  tar -zxvf ${FILE_DIR}/$tool-$version-$HOST_ARCH.tgz -C $PLUGIN_DIR
  echo_green "***** $tool plugin installed ******"
}

function main() {
  install_binary helm v3.12.2
  install_binary helmfile 0.155.1
  install_helm_plugin helm-diff v3.8.1
}

main
