#!/bin/bash
#DISK=/dev/sde1
MOUNTPOINT=/media/backup
OTHER=/home/shares
mount UUID=58d876a4-7b5f-492a-8b23-539834ad0a4d ${MOUNTPOINT}
#mount -t ext4 ${DISK} ${MOUNTPOINT}

if ! [ -e ${MOUNTPOINT}/dummy ]
then
        echo "Backup disk not connected on `date`" >> /var/www/logs/didnothappen
        echo "Backup disk not connected on `date`" | mail -s "Backup disk notification" gswamy@gmsconsultants.co.in,redalert@aware.co.in
        exit
fi

# first, delete the oldest backup

if [ -d $MOUNTPOINT/backup.5 ]
then
        rm -rf $MOUNTPOINT/backup.5
fi

# now, shift the middle backups
if [ -d $MOUNTPOINT/backup.4 ]
then
        mv $MOUNTPOINT/backup.4 $MOUNTPOINT/backup.5
fi

if [ -d $MOUNTPOINT/backup.3 ]
then
        mv $MOUNTPOINT/backup.3 $MOUNTPOINT/backup.4
fi

if [ -d $MOUNTPOINT/backup.2 ]
then
        mv $MOUNTPOINT/backup.2 $MOUNTPOINT/backup.3
fi

if [ -d $MOUNTPOINT/backup.1 ]
then
        mv $MOUNTPOINT/backup.1 $MOUNTPOINT/backup.2
fi

# make a hard link copy of latest snapshot
if [ -d $MOUNTPOINT/backup.0 ]
then
        cp -al $MOUNTPOINT/backup.0 $MOUNTPOINT/backup.1
fi

rsync --stats -av --numeric-ids  ${OTHER} ${MOUNTPOINT}/backup.0/ > /var/www/logs/data-sync-`date +%F`.log

# update the time on the latest snapshot
touch ${MOUNTPOINT}/backup.0

umount ${MOUNTPOINT}

echo "Backup script on gms server successfully completed on `date`" | mail -s "Backup disk notification" -t gswamy@gmsconsultants.co.in,support@aware.co.in
