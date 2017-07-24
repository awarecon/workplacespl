#!/bin/bash
MOUNTPOINT=/media/backup
mount UUID=100e834c-9d2f-4c7a-9358-b347fa35c2f0 ${MOUNTPOINT}

if ! [ -e ${MOUNTPOINT}/dummy ]
then
        echo "Backup disk not connected on `date`" >> /var/www/logs/didnothappen
        echo "Backup disk not connected on `date`" | mail -s "Backup disk notification" vishal@greenchef.in,gyan@greenchef.in,redalert@aware.co.in
        exit
fi


/etc/init.d/postfix stop
/etc/init.d/cron stop
killall fetchmail
dir=$(date +%b-%d-%y)
#mkdir /media/backup/$dir
ls /home/backup/received > /tmp/receivelist

for i in `cat /tmp/receivelist`
do
	tar -zcvf /home/backup/received/$i.tar.gz /home/backup/received/$i
	mkdir /media/backup/mailsbackup/$dir
	mkdir /media/backup/mailsbackup/$dir/receive
	rsync -av --stats /home/backup/received/$i.tar.gz /media/backup/mailsbackup/$dir/receive/
	rm /home/backup/received/$i.tar.gz
	rm /home/backup/received/$i/new/*
	rm /home/backup/received/$i/cur/*
	rm /home/backup/received/$i/tmp/*
done
ls /home/backup/sent > /tmp/sentlist
for i in `cat /tmp/sentlist`
do
	tar -zcvf /home/backup/sent/$i.tar.gz /home/backup/sent/$i
	mkdir /media/backup/mailsbackup/$dir/sent
	rsync -av --stats /home/backup/sent/$i.tar.gz /media/backup/mailsbackup/$dir/sent/
	rm /home/backup/sent/$i.tar.gz
	rm /home/backup/sent/$i/new/*
	rm /home/backup/sent/$i/cur/*
	rm /home/backup/sent/$i/tmp/*
done

mkdir -p /media/backup/maildump
mysqldump -uroot -pIOS8gtn7000 mail > /media/backup/maildump/mail.sql
/etc/init.d/postfix start
/etc/init.d/cron start
mkdir ${MOUNTPOINT}/etcbackup
rsync --stats -av --numeric-ids --delete /etc/ ${MOUNTPOINT}/etcbackup/ > ${MOUNTPOINT}/etcbackup/etcsync.log
echo "Monthly backup successfully completed at Workplace" | mail -s "Workplace backup" support@aware.co.in
umount ${MOUNTPOINT}
