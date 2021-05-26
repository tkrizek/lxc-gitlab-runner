#!/usr/bin/env bash

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=base.sh
source "${currentDir}"/base.sh

set -eEo pipefail

failure() {
    cat "/var/log/lxc/$CONTAINER_ID.log" ||:
    exit $SYSTEM_FAILURE_EXIT_CODE
}
# trap any error, and mark it as a system failure.
trap failure ERR

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

    echo "Starting LXC container..."
    lxc-start --logfile "/var/log/lxc/$CONTAINER_ID.log" -n "$CONTAINER_ID"

    echo "Waiting up to 60s for working DNS resolution..."
    lxc-attach -n "$CONTAINER_ID" -- /bin/bash -c "for i in {1..60}; do if getent hosts $SERVER_HOST &>/dev/null; then exit 0; fi; sleep 1; done; exit 1"

    echo "Waiting up to 30s for systemd startup..."
    lxc-attach -n "$CONTAINER_ID" -- /bin/bash -c "for i in {1..30}; do if systemctl is-system-running -q &>/dev/null; then exit 0; fi; sleep 1; done; exit 1"

    # Ensure TMPDIR is created inside container as well (e.g. for artifact download)
    lxc-attach -n "$CONTAINER_ID" -- /bin/bash -c "mkdir $TMPDIR"
}

echo "Running in $CONTAINER_ID"

start_container

echo "Container ready"
