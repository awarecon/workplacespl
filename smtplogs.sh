#!/bin/bash
##remove old html files
rm -rf /var/www/maillogs/*.html
##Preparation of pre in html files
echo -e "<pre>"> /var/www/maillogs/index.html
pflogsumm /var/log/mail.log | grep -v "backup" >> /var/www/maillogs/index.html
echo -e "</pre>" >> /var/www/maillogs/index.html
chown -R www-data.www-data /var/www/maillogs
chmod -R 775 /var/www/maillogs
##You should read the email details from browser pointing to above directory and html
