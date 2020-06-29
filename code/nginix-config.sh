#
mkdir -p /etc/nginx
cat >>/etc/nginx/nginx.conf<<EOF
events { }

stream {
    upstream stream_backend {
        least_conn;
        server 10.6.230.105:6443 ;
        server 10.6.230.8:6443 ;
    }
    server {
        listen        6443 ;
        proxy_pass    stream_backend ;
        proxy_timeout 3s ;
        proxy_connect_timeout 1s ;
    }
}
EOF
#
docker pull nginx > /dev/null 2>&1
#
docker run --name proxy --restart=always -v /etc/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -p 6443:6443 -d nginx > /dev/null 2>&1
#
sleep 3s
#
docker container ls
