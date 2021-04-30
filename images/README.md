# Container images with systemd

## Why?

As a lightweight alternative to VMs. Systemd is necessary for some integration
/ packaging tests utilized by Knot Resolver.

## What

Images are ready-to-use with any OCI container runner that supports systemd
(podman, LXC, ...). They are configured with systemd and you get auto
logged in as root.

Images are pre-installed to be used as containers for GitLab Runner with custom
LXC executor (this repo).

## Building

To avoid copying common files, they are placed directly in `images/` directory.
Consequently, it needs to be used as the context directory for the build.

```
# PWD => images/

podman build -t registry.nic.cz/labs/lxc-gitlab-runner/debian-10 -f debian-10 .
```
