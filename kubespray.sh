#!/usr/bin/env sh

# git clone https://github.com/kubernetes-incubator/kubespray.git

ENGINE="podman"
INVENTORY_DIR="$(pwd)/inventory"
SSH_KEY="${HOME}/.ssh"
KUBESPRAY_VERSION="v2.17.0"
KUBESPRAY_IMAGE="quay.io/kubespray/kubespray"

exec_container() {
  local COMMAND="${1}"
  ${ENGINE} run --rm -it --name kubespray \
    -v "${INVENTORY_DIR}":/kubespray/inventory:z \
    -v "${SSH_KEY}":/root/.ssh \
    "${KUBESPRAY_IMAGE}:${KUBESPRAY_VERSION}" \
    bash -c "${COMMAND}" \
    | tee kubespray.log
 }

case "${1}" in
  cluster)
    CLUSTER="ansible-playbook -i /kubespray/inventory/inventory.ini --private-key /root/.ssh/id_rsa --become --become-user=root cluster.yml"
    exec_container "${CLUSTER}"
    ;;

  reset)
    RESET="ansible-playbook -i /kubespray/inventory/inventory.ini --private-key /root/.ssh/id_rsa --become --become-user=root reset.yml"
    exec_container "${RESET}"
    ;;

  ping)
    PING="ansible -i /kubespray/inventory/inventory.ini all -m ping"
    exec_container "${PING}"
    ;;

  remove)
    REMOVE_NODE="ansible-playbook -i /kubespray/inventory/inventory.ini --private-key /root/.ssh/id_rsa --become --become-user=root remove-node.yml"
    exec_container "$REMOVE_NODE"
    ;;

  *)
    echo "Usage: $0 [cluster, reset, ping, remove]" >&2
    ;;
esac
