#!/bin/bash

# Define nodes
NODES=("controlplane" "node01" "node02" "node03")
NFS_SERVER="192.168.1.17"
NFS_PATH="/nfs/kubedata"
MOUNT_POINT="/mnt"

# Function to mount NFS on a node
mount_nfs() {
    local node=$1
    echo "Mounting NFS on $node..."
    vagrant ssh "$node" -c "
        sudo apt-get update -y
        sudo apt-get install -y nfs-common
        sudo mount -t nfs $NFS_SERVER:$NFS_PATH $MOUNT_POINT
        df -h | grep $MOUNT_POINT
    " & 
}

# Mount NFS on all nodes in parallel
for node in "${NODES[@]}"; do
    mount_nfs "$node"
done

# Wait for all background jobs to finish
wait

echo "NFS mount process completed!"

# Function to unmount NFS
unmount_nfs() {
    local node=$1
    echo "Unmounting NFS on $node..."
    vagrant ssh "$node" -c "sudo umount -f -l $MOUNT_POINT"
}

# Uncomment below lines if you want to unmount NFS
# for node in "${NODES[@]}"; do
#     unmount_nfs "$node"
# done
# echo "NFS unmount process completed!"
