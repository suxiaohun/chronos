FILE_DIR="./packages/tools"
HOST_ARCH="amd64"

PLUGIN_DIR="$HOME/.local/share/helm/plugins"

. scripts/echo-color.sh

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
  mkdir -p $PLUGIN_DIR/$tool
  tar -zxvf ${FILE_DIR}/$tool-$version-$HOST_ARCH.tgz -C $PLUGIN_DIR
  echo_green "***** $tool plugin installed ******"
}

function main() {
  install_binary yq v4.44.3
  install_binary helm v3.16.1
  install_binary helmfile 0.168.0
  install_helm_plugin helm-diff v3.9.10
}

main