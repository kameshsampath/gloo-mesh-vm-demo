---
title: Overview
summary: Gloo Mesh VM Demo

authors:
  - Kamesh Sampath<kamesh.sampath@hotmail.com>
date: 2022-01-10
---

In my [blog](https://kamesh-sampath.medium.com/letting-vms-talk-to-kubernetes-6a2347e05101#c8ac-eac3d56e01f6) I discussed on a technique on how to make your VMS talk to Kubernetes  Services over  cluster IP and service IP i.e. without using Load Balancers.

In this demo I extend that technique to [Isito](https://istio.io) and explore how to onboard Virtual Machines(VM) workloads. We also go a step further in by configuring few Service Mesh operations like Traffic Splitting, Access Policies using [Gloo Mesh](https://solo.io/products/gloo-mesh) which will span both Kubernetes and Virtual Machine services.

![Demo Architecture](images/architecture.png)
<figure markdown> 
  <figcaption>Demo Architecture</figcaption>
</figure>

---8<--- "includes/abbrevations.md"
