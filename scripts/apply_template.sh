#!/bin/bash
sed -e "s/NFS_IP/$2/" -e "s/DISK_SIZE_KAFKA/$3/" -e "s/DISK_SIZE/$4/" $1 > "${1%.*}"
