#!/usr/bin/env bash

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=base.sh
source "${currentDir}"/base.sh

set -eo pipefail

# trap any error, and mark it as a system failure.
trap 'exit $SYSTEM_FAILURE_EXIT_CODE' ERR

start_container() {
    if lxc-info "$CONTAINER_ID" >/dev/null 2>&1; then
        echo 'Found old container, deleting'
        lxc-destroy -f "$CONTAINER_ID"
    fi

    mkdir -p "$CACHE_DIR"
    echo "Creating LXC container..."
    lxc-create \
        --template oci \
        --name "$CONTAINER_ID" \
        -- \
        -u "docker://$IMAGE"

        #--tty \
        #--name "$CONTAINER_ID" \
        #--volume "$CACHE_DIR:/home/user/cache":Z \
        #"${PODMAN_RUN_ARGS[@]}" \
        #"$IMAGE"\
        #sleep 999999999

    echo "Starting LXC container..."
    lxc-start -n "$CONTAINER_ID"

    echo "Waiting up to 60s for working DNS resolution..."
    lxc-attach -n "$CONTAINER_ID" -- /bin/bash -c "for i in {1..60}; do if getent hosts $SERVER_HOST &>/dev/null; then exit 0; fi; sleep 1; done; exit 1"
}

echo "Running in $CONTAINER_ID"

start_container

echo "Container ready"
