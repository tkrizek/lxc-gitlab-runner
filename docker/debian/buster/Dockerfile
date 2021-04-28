FROM debian:buster
RUN apt-get update && apt-get install -y systemd sudo dhcpcd5
RUN mkdir -p /etc/systemd/system/console-getty.service.d
COPY console-getty.conf /etc/systemd/system/console-getty.service.d/override.conf
CMD ["/sbin/init"]
