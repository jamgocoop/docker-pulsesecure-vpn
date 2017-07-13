FROM alpine:3.6
MAINTAINER Jamgo Coop <info@jamgo.coop>

RUN mkdir -p /etc/vpnc
COPY patch.diff /tmp
COPY vpnc-script /etc/vpnc
RUN chmod +x /etc/vpnc/vpnc-script

# Install required packages
RUN set -x; \
    apk update && \
    apk add --no-cache build-base gcc binutils binutils-doc gcc-doc g++ make autoconf automake libtool git zlib gettext gnutls-dev libxml2-dev linux-headers supervisor iptables && \
	cd tmp && \
	git clone git://git.infradead.org/users/dwmw2/openconnect.git && \
	cd openconnect && \
	git apply /tmp/patch.diff && \
	./autogen.sh && \
	./configure --with-vpnc-script=/etc/vpnc/vpnc-script && \
	make && \
	make install && \
	apk del --no-cache build-base gcc binutils binutils-doc gcc-doc g++ make autoconf automake libtool git && \
	cd /tmp && \
	rm -rf *

COPY startup.sh /root/startup.sh

RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \
    echo "[program:startup]" >> /etc/supervisord.conf && \
    echo "command=/root/startup.sh" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/fd/1" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "autorestart=false" >> /etc/supervisord.conf && \
    echo "startretries=0" >> /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]