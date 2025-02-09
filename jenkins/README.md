# Kubernetes NFS Subdir External Provisioner

**NFS subdir external provisioner** is an automatic provisioner that use your _existing and already configured_ NFS server to support dynamic provisioning of Kubernetes Persistent Volumes via Persistent Volume Claims. Persistent volumes are provisioned as `${namespace}-${pvcName}-${pvName}`.

Note: This repository is migrated from https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client. As part of the migration:
- The container image name and repository has changed to `registry.k8s.io/sig-storage` and `nfs-subdir-external-provisioner` respectively.
- To maintain backward compatibility with earlier deployment files, the naming of NFS Client Provisioner is retained as `nfs-client-provisioner` in the deployment YAMLs.
- One of the pending areas for development on this repository is to add automated e2e tests. If you would like to contribute, please raise an issue or reach us on the Kubernetes slack #sig-storage channel.

## How to deploy NFS Subdir External Provisioner to your cluster

To note again, you must _already_ have an NFS Server.

### With Helm

Follow the instructions from the helm chart [README](charts/nfs-subdir-external-provisioner/README.md).

The tl;dr is

```console
$ helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
$ helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=x.x.x.x \
    --set nfs.path=/exported/path
```
