#!/usr/bin/env bash

TMPDIR=$(pwd)

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=base.sh
source "${currentDir}"/base.sh

echo "Deleting container $CONTAINER_ID"

lxc-stop -n "$CONTAINER_ID"
lxc-destroy -f -n "$CONTAINER_ID"

# Delete leftover files in /tmp
rm -r "$TMPDIR"

exit 0
