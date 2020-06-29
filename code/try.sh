#!/bin/bash
#
#ldDevice="/dev/loop22"
#ldDeviceesc=$(echo $ldDevice | sed 's_/_\\/_g')
#echo $ldDeviceesc
#cat template/mount.sh > loopDevice/mount.sh
#find1="<device>"
#find2="<mountLocation>"
#mntLoc="/mnt/dvc1"
#mntLocesc=$(echo $mntLoc | sed 's_/_\\/_g')
#echo $mntLocesc
#sed -i "s/<device>/$ldDeviceesc/g" loopDevice/mount.sh
#sed -i "s/<mountLocation>/$mntLocesc/g" loopDevice/mount.sh
echo "#!/bin/bash" > code/nginix-config.sh
echo "#" > code/nginix-config.sh
echo "mkdir -p /etc/nginx" >> code/nginix-config.sh
echo "cat >>/etc/nginx/nginx.conf<<EOF" >> code/nginix-config.sh
echo "events { }" >> code/nginix-config.sh
echo "" >> code/nginix-config.sh
echo "stream {" >> code/nginix-config.sh
echo "    upstream stream_backend {" >> code/nginix-config.sh
echo "        least_conn;" >> code/nginix-config.sh
echo "        server <node1>:6443 ;" >> code/nginix-config.sh
echo "    }" >> code/nginix-config.sh
echo "    server {" >> code/nginix-config.sh
echo "        listen        6443 ;" >> code/nginix-config.sh
echo "        proxy_pass    stream_backend ;" >> code/nginix-config.sh
echo "        proxy_timeout 3s ;" >> code/nginix-config.sh
echo "        proxy_connect_timeout 1s ;" >> code/nginix-config.sh
echo "    }" >> code/nginix-config.sh
echo "EOF" >> code/nginix-config.sh
echo "#" >> code/nginix-config.sh
echo "docker run --name proxy --restart=always -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -p 6443:6443 -d nginx " >> code/nginix-config.sh
echo "#" >> code/nginix-config.sh
echo "sleep 3s" >> code/nginix-config.sh
echo "#" >> code/nginix-config.sh
echo "docker container ls" >> code/nginix-config.sh
