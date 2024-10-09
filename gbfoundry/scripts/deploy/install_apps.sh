. scripts/echo-color.sh

function install_apps() {
    if [[ -z "${LABELS}" ]]; then
         for group in {k8s,devops,mes};do
              helmfile -l app=${group} ${FILE_VARS[@]} sync
              print_result
         done
    else
         helmfile ${LABEL_VARS[@]} ${FILE_VARS[@]} sync
         print_result
    fi
}

function print_result() {
    if [[ $? -eq 0 ]]; then
       echo_green "****** helmfile exec install apps succeed ******"
    else
       echo_red "****** helmfile exec install apps failed ******"
       exit 1
    fi
}



function main() {
   while [[ $# -gt 0 ]]; do
      case "$1" in
          --environment|-e)
              ENVIRONMENT="$2"
              shift
              shift
              ;;
          --env-files|-f)
              FILES="$2"
              shift
              shift
              ;;
          --label|-l)
              LABELS="$2"
              shift
              shift
              ;;
          *)
              print_usage;
              exit 1;
      esac
   done

   install_apps
}

main "$@"
