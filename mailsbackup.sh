#!/bin/bash
MOUNTPOINT=/media/backup
mount UUID=58d876a4-7b5f-492a-8b23-539834ad0a4d ${MOUNTPOINT}

if ! [ -e ${MOUNTPOINT}/dummy ]
then
        echo "Backup disk not connected on `date`" >> /var/www/logs/didnothappen
        echo "Backup disk not connected on `date`" | mail -s "Backup disk notification" gswamy@gmsconsultants.co.in,redalert@aware.co.in
        exit
fi


/etc/init.d/postfix stop
dir=$(date +%b-%d-%y)
mkdir $dir
ls /home/backup/receive > /tmp/receivelist

for i in `cat /tmp/receivelist`
do
tar -zcvf /home/backup/receive/$i.tar.gz /home/backup/receive/$i
mkdir /media/backup/mailsbackup/$dir
mkdir /media/backup/mailsbackup/$dir/receive
rsync -av --stats /home/backup/receive/$i.tar.gz /media/backup/mailsbackup/$dir/receive/
rm /home/backup/receive/$i.tar.gz
rm /home/backup/receive/$i/Maildir/new/*
rm /home/backup/receive/$i/Maildir/cur/*
rm /home/backup/receive/$i/Maildir/tmp/*
done
ls /home/backup/sent > /tmp/sentlist
for i in `cat /tmp/sentlist`
do
tar -zcvf /home/backup/sent/$i.tar.gz /home/backup/sent/$i
mkdir /media/backup/mailsbackup/$dir/sent
rsync -av --stats /home/backup/sent/$i.tar.gz /media/backup/mailsbackup/$dir/sent/
rm /home/backup/sent/$i.tar.gz
rm /home/backup/sent/$i/Maildir/new/*
rm /home/backup/sent/$i/Maildir/cur/*
rm /home/backup/sent/$i/Maildir/tmp/*
done
/etc/init.d/postfix start
umount ${MOUNTPOINT}
rsync --stats -av --numeric-ids --delete /etc/ /media/backup/etcbackup/ > /media/backup/etcbackup/etcsync.log
echo "Monthly backup successfully completed at GMS Consultants" | mail -s "GMS backup" support@aware.co.in
