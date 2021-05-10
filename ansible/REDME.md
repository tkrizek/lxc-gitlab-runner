# Ansible Role for Deploying lxc-gitlab-runner

## Supported host OS

- Ubuntu 20.04

## Usage

setup.yaml playbook is used for both initial setup and runner registration.

To skip runner registration, use empty token when prompted. To register runner
to multiple projects/groups, re-run the playbook with different registration
tokens.

```
ansible-playbook -i inventory/host setup.yaml
```
