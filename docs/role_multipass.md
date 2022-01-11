---
title: multipass
summary: Ansible Role to create Virtual Machines using multipass
authors:
  - Kamesh Sampath<kamesh.sampath@hotmail.com>
date: 2022-01-10
---

This role helps in setting up [multipass](https://multipass.run) Virtual Machines.

## Requirements

- [multipass](https://multipass.run)

## Variables

- `multipass_vms` - defines a dictionary of VMs that needs to be created,

```yaml
multipass_vms:
 # the name of the VM
 - name: mgmt
   # cpus to allocate
   cpus: 4
   # memory to allocate
   mem: 8g
   # disk size
   disk: 30g
   # roles of this vm
   role:
    # tags this machine to be grouped under `kubernetes` in Ansible Hosts file
    - kubernetes
    - gloo
    - management
```

The multipass role also generates an Ansible hosts inventory using the template from `{{ playbook_dir }}/templates/hosts.j2`.
