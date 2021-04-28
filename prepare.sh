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

    lxc-start -n "$CONTAINER_ID"
}

install_dependencies() {
    # Copy gitlab-runner binary from the server into the container
    lxc file push /usr/bin/gitlab-runner "$CONTAINER_ID"/usr/bin/gitlab-runner

    # Install bash in systems with APK (e.g., Alpine)
    lxc-execute -n "$CONTAINER_ID" sh -c 'if ! type bash >/dev/null 2>&1 && type apk >/dev/null 2>&1 ; then echo "APK based distro without bash"; apk add bash; fi'

    # Install git in systems with APT (e.g., Debian)
    lxc-execute -n "$CONTAINER_ID" /bin/bash -c 'if ! type git >/dev/null 2>&1 && type apt-get >/dev/null 2>&1 ; then echo "APT based distro without git"; apt-get update && apt-get install --no-install-recommends -y ca-certificates git; fi'
    # Install git in systems with DNF (e.g., Fedora)
    lxc-execute -n "$CONTAINER_ID" /bin/bash -c 'if ! type git >/dev/null 2>&1 && type dnf >/dev/null 2>&1 ; then echo "DNF based distro without git"; dnf install --setopt=install_weak_deps=False --assumeyes git; fi'
    # Install git in systems with APK (e.g., Alpine)
    lxc-execute -n "$CONTAINER_ID" /bin/bash -c 'if ! type git >/dev/null 2>&1 && type apk >/dev/null 2>&1 ; then echo "APK based distro without git"; apk add git; fi'
    # Install git in systems with YUM (e.g., RHEL<=7)
    lxc-execute -n "$CONTAINER_ID" /bin/bash -c 'if ! type git >/dev/null 2>&1 && type yum >/dev/null 2>&1 ; then echo "YUM based distro without git"; yum install --assumeyes git; fi'
}

echo "Running in $CONTAINER_ID"

start_container
install_dependencies
