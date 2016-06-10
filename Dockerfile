FROM ubuntu

MAINTAINER Dinko Korunic <dkorunic@haproxy.com>

LABEL Name HAProxy OSS
LABEL Release OSS Edition
LABEL Vendor HAProxy
LABEL Version 1.6.5
LABEL RUN /usr/bin/docker -d IMAGE

ENV HAPROXY_BRANCH 1.6
ENV HAPROXY_MINOR 1.6.5
ENV HAPROXY_MD5 5290f278c04e682e42ab71fed26fc082
ENV HAPROXY_SRC_URL http://www.haproxy.org/download/

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

RUN apt-get update && \
    apt-get install -y libssl1.0.0 zlib1g libpcre3 tar curl socat && \
    apt-get install -y gcc make libc6-dev libssl-dev libpcre3-dev zlib1g-dev && \
    curl -sfSL "$HAPROXY_SRC_URL/$HAPROXY_BRANCH/src/haproxy-$HAPROXY_MINOR.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_MD5  haproxy.tar.gz" | md5sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy TARGET=linux2628 CPU=generic USE_PCRE=1 USE_REGPARM=1 USE_OPENSSL=1 \
                            USE_ZLIB=1 USE_TFO=1 USE_LINUX_TPROXY=1 \
                            all install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    rm -rf /tmp/haproxy && \
    apt-get purge -y --auto-remove gcc make libc6-dev libssl-dev libpcre3-dev zlib1g-dev && \
    apt-get clean

ADD ./cfg_files/cli /usr/bin/cli
ADD ./cfg_files/haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 80 443

CMD ["/usr/local/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
