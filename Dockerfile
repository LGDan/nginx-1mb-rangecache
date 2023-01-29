FROM nginx:alpine AS builder

# nginx:alpine contains NGINX_VERSION environment variable, like so:
# ENV NGINX_VERSION 1.15.0

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p')
RUN mkdir /usr/src
RUN tar -zxC /usr/src -f nginx.tar.gz
RUN cd /usr/src/nginx-$NGINX_VERSION && \
    ./configure \
        --with-compat $CONFARGS \
        --with-http_slice_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx \
        --pid-path=/var/log/nginx/nginx.pid && \
  make && make install

FROM nginx:alpine

RUN apk add --no-cache pcre

COPY --from=builder /usr/src/nginx-1.23.3/objs/nginx /usr/sbin/nginx
RUN rm /etc/nginx/conf.d/default.conf

STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
