#Run this as sudo.
cd /home/pi/
cp startharvester.sh /etc/init.d/
chmod +x /etc/init.d/startharvester.sh
update-rc.d startharvester.sh defaults 100

 
