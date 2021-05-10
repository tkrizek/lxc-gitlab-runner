# LXC GitLab Runner

Custom GitLab Runner that uses LXC to run containers with systemd and nesting
support.

The intended use-case is to allow testing with systemd features inside CI.
Project assumes the CI is only used to run trusted code and the host machine is
disposable and used only for testing. Security features (apparmor, unprivileged
containers, ...) aren't used in favor of available features and configuration
simplicity. Use at your own risk.

Plain LXC (without LXD) is used to run operate the containers. Containers run
privileged to support nesting and various systemd features (e.g. network
namespaces).

## Why use LXC?

- docker doesn't support systemd
- podman could work, but isn't available on one of our target platforms (armv7 with OpenWRT)
- LXC can run OCI container images created by podman/docker, see `images/`

## Available images

The LXC runner has some dependencies that it expects inside the image. It also
expects that the image will run systemd. Pre-configured image templates are
defined in `images/` and ready-to-run containers with systemd are available at:
https://gitlab.nic.cz/labs/lxc-gitlab-runner/container_registry

Podman can also be used to run these images directly:

```
$ podman run -ti registry.nic.cz/labs/lxc-gitlab-runner/debian-10
(container)# systemctl poweroff -i  # to turn off the container
```

## Nesting with podman

Podman provides a simple way to run nested containers inside the initialized
LXC container. However, GitLab Runner sets some environment variables that may
prevent proper operation. Specifically, the `$TMPDIR` variable should be unset
to properly allow nesting with podman, otherwise you get following error:

```
stat /tmp/custom-executor048330180: no such file or directory
Error: Error initializing destination containers-storage:[overlay@/var/lib/containers/storage+/run/containers/storage:overlay.mountopt=nodev,metacopy=on]registry.nic.cz/labs/lxc-gitlab-runner/fedora-34:podman: error creating a temporary directory: stat /tmp/custom-executor048330180: no such file or directory
```
