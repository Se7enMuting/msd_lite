#Build image
FROM phusion/baseimage:jammy-1.0.4 AS builder

CMD ["/sbin/my_init"]

RUN echo 'APT::Get::Clean=always;' >> /etc/apt/apt.conf.d/99AutomaticClean

RUN apt-get update -qqy \
    && DEBIAN_FRONTEND=noninteractive apt-get -qyy install \
	--no-install-recommends \
	build-essential \
	cmake \
	fakeroot \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /tmp/msd_lite

COPY . .

RUN mkdir build && cd build && cmake .. && make -j 8 && make install

#Runtime image
FROM debian:stable

COPY --from=builder /usr/local/bin/msd_lite /usr/local/bin/msd_lite

CMD ["/usr/local/bin/msd_lite", "-c", "/etc/msd_lite.conf"]
