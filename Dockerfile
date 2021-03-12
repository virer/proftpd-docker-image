FROM alpine:3.13 AS builder

ENV PROFTPD_VERSION 1.3.7a

ENV PROFTPD_DEPS \
  g++ \
  gcc \
  libc-dev \
  make \
  libressl-dev \
  gettext \
  sqlite-dev \
  mariadb-dev

RUN set -x \
    && apk add --no-cache --virtual .persistent-deps \
        ca-certificates \
        curl \
        openssh \
    && apk add --no-cache --virtual .build-deps \
        $PROFTPD_DEPS \
    && curl -fSL ftp://ftp.proftpd.org/distrib/source/proftpd-${PROFTPD_VERSION}.tar.gz -o proftpd.tgz \
    && tar -xf proftpd.tgz \
    && rm proftpd.tgz \
    && mv proftpd-${PROFTPD_VERSION} /opt/build 

RUN set -x \
    && cd /opt/build \
    && sed -i 's/__mempcpy/mempcpy/g' lib/pr_fnmatch.c \
    && ./configure \
        --enable-openssl \
        --with-modules=mod_sftp \
    && make \
    && make install 

RUN set -x \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''

# ************************************************************************
# Multistage build
FROM alpine:3.13

# The following line for is for testing purpose only, you should replace it by your own key
COPY --from=builder /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_rsa_key /etc/ssh/

COPY --from=builder /usr/local/ /usr/local/
COPY proftpd.conf /usr/local/etc/proftpd/
COPY ftp.passwd /usr/local/etc/ftp/
COPY ftp.group  /usr/local/etc/ftp/

RUN set -x \
    && addgroup -Sg 1007 mysftp 2>/dev/null \
    && adduser -h /var/www -s /usr/sbin/nologin -H -u 1007 -D -G mysftp mysftp \
    && chmod 400 /usr/local/etc/ftp/ftp.passwd /usr/local/etc/ftp/ftp.group \
    && chown 0   /usr/local/etc/ftp/ftp.passwd /usr/local/etc/ftp/ftp.group \
    && chown 0 /etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_rsa_key 
    

# For testing inside container purpose only:
# RUN apk add --no-cache openssh

EXPOSE 2222

CMD ["/usr/local/sbin/proftpd", "-n", "-c", "/usr/local/etc/proftpd/proftpd.conf" ]
