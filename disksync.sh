#!/bin/bash
rsync -av --stats /media/backup/* /media/drive/ > /media/drive/disksync.log &
echo "Rsync completed at GMS Consultants" | mail -s "GMS Rsync" support@aware.co.in,ravi@aware.co.in
