#!/bin/bash
#
# Start Nginx container for load balancing
echo "[TASK 1] create Nginx config"
mkdir -p /etc/nginx
cat >>/etc/nginx/nginx.conf<<EOF
events { }
        
stream {
    upstream stream_backend {
        least_conn;
        server <node1>:6443 ;
        server <node2>:6443 ;
        server <node3>:6443 ;
    }
    server {
        listen        6443 ;
        proxy_pass    stream_backend ;
        proxy_timeout 3s ;
        proxy_connect_timeout 1s ;
    } 
}
EOF
# Start Nginx container for load balancing
echo "[TASK 2] Start Nginx container for load balancing"
docker run --name proxy \
    --restart=always \
    -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    -p 6443:6443 \
    -d nginx 
sleep 3s
# Validate Nginx container
echo "[TASK 3] Validate Nginx container"
docker container ls 