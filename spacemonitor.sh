#!/bin/sh
MOUNTPOINT=/media/backup
mount UUID=05ef366b-dd6d-4a8d-ad43-1c5a09d48317 ${MOUNTPOINT}
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 75 ]; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
     mail -s "Alert: Almost out of disk space $usep%" support@aware.co.in
  fi
done
umount ${MOUNTPOINT}


