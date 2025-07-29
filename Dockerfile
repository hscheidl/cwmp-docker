FROM debian:bookworm

RUN apt-get update && apt-get install -y git cmake build-essential pkg-config libjson-c-dev libcurl4-openssl-dev libssl-dev libmxml-dev uuid-dev zlib1g-dev lua5.1 liblua5.1-dev rsyslog iproute2 libnl-3-dev libnl-genl-3-dev libnl-genl-3-dev libnl-route-3-dev ntp

# libjson-c
RUN git clone https://github.com/json-c/json-c.git /opt/dev/json-c
WORKDIR /opt/dev/json-c/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/ && make && make install

# libubox
RUN git clone https://git.openwrt.org/project/libubox.git /opt/dev/libubox
WORKDIR /opt/dev/libubox/build
RUN cmake .. -DBUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=/usr && make && make install

# libuci
RUN git clone https://git.openwrt.org/project/uci.git /opt/dev/uci
WORKDIR /opt/dev/uci/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/ && make && make install

# libubus
RUN git clone https://git.openwrt.org/project/ubus.git /opt/dev/ubus
WORKDIR /opt/dev/ubus/build
RUN cmake .. -DBUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=/usr && make && make install

# mxml
RUN git clone https://github.com/michaelrsweet/mxml /opt/dev/mxml
WORKDIR /opt/dev/mxml
RUN ./configure --prefix=/usr --enable-threads --enable-shared --enable-static && make && make install

# bbfdm
RUN git clone https://dev.iopsys.eu/bbf/bbfdm.git /opt/dev/bbfdm
WORKDIR /opt/dev/bbfdm/build
RUN cmake .. -DBBF_VENDOR_PREFIX="X_IOWRT_EU_" -DBBF_MAX_OBJECT_INSTANCES=255 -DBBFDMD_MAX_MSG_LEN=1048576 -DBBF_SCHEMA_FULL_TREE=ON -DCMAKE_INSTALL_PREFIX=/ && make && make install
RUN mkdir -p /etc/bbfdm/services
RUN mkdir -p /usr/share/bbfdm/micro_services
RUN cp ../utilities/bbf_configd /usr/sbin/
RUN cp -f ../utilities/files/usr/share/bbfdm/scripts/bbf_api /usr/share/bbfdm/scripts/
RUN cp -f libbbfdm/libcore.so /usr/share/bbfdm/micro_services/core.so

# sysmngr
RUN git clone https://dev.iopsys.eu/system/sysmngr.git /opt/dev/sysmngr
WORKDIR /opt/dev/sysmngr
RUN make -C ./src/ clean
RUN make -C ./src/ \
		CFLAGS+="-DBBF_VENDOR_PREFIX=\\\"X_IOWRT_EU_\\\"" \
		SYSMNGR_VENDOR_CONFIG_FILE='y' \
		SYSMNGR_MEMORY_STATUS='y' \
		SYSMNGR_PROCESS_STATUS='y' \
		SYSMNGR_SUPPORTED_DATA_MODEL='y' \
		SYSMNGR_FIRMWARE_IMAGE='y' \
		SYSMNGR_REBOOTS='y' \
		SYSMNGR_NETWORK_PROPERTIES='y' \
		SYSMNGR_VENDOR_EXTENSIONS='y' \
		SYSMNGR_FWBANK_UBUS_SUPPORT='y'
RUN cp -f ./src/sysmngr /usr/sbin/
RUN mkdir /etc/sysmngr

# wifidmd
RUN git clone https://dev.iopsys.eu/bbf/wifidmd.git /opt/dev/wifidmd
WORKDIR /opt/dev/wifidmd
RUN make -C ./src/ clean && make -C ./src/ WIFIDMD_ENABLE_WIFI_DATAELEMENTS='y'
RUN cp -f ./src/wifidmd /usr/sbin/

# netmngr
RUN git clone https://dev.iopsys.eu/network/netmngr.git /opt/dev/netmngr
WORKDIR /opt/dev/netmngr
RUN make -C ./src/ clean
RUN make -C ./src/ NETMNGR_GRE_OBJ=y NETMNGR_IP_OBJ=y NETMNGR_ROUTING_OBJ=y NETMNGR_PPP_OBJ=y NETMNGR_ROUTER_ADVERTISEMENT_OBJ=y NETMNGR_IPV6RD_OBJ=y
RUN cp -f ./src/libnetmngr.so /usr/share/bbfdm/micro_services/netmngr.so

# tr143d
RUN git clone https://dev.iopsys.eu/bbf/tr143d.git /opt/dev/tr143d
WORKDIR /opt/dev/tr143d
RUN make -C ./src/ clean && make -C ./src/
RUN cp -rf ./scripts/* /usr/share/bbfdm/scripts/
RUN mkdir -p /usr/share/bbfdm/micro_services/netmngr
RUN cp -f ./src/libtr143d.so /usr/share/bbfdm/micro_services/netmngr/libtr143d.so

# tr471d
RUN git clone https://dev.iopsys.eu/bbf/tr471d.git /opt/dev/tr471d
WORKDIR /opt/dev/tr471d
RUN make -C ./src/ clean && make -C ./src/
RUN cp -f ./src/libtr471d.so /usr/share/bbfdm/micro_services/netmngr/libtr471d.so

# twamp-light
RUN git clone https://dev.iopsys.eu/bbf/twamp-light.git /opt/dev/twamp-light
WORKDIR /opt/dev/twamp-light
RUN make -C . clean && make -C .
RUN cp -f ./libtwamp.so /usr/share/bbfdm/micro_services/netmngr/libtwamp.so

# udpecho
RUN git clone https://dev.iopsys.eu/bbf/udpecho.git /opt/dev/udpecho
WORKDIR /opt/dev/udpecho
RUN make -C ./src/ clean && make -C ./src/
RUN cp -f ./src/libudpechoserver.so /usr/share/bbfdm/micro_services/netmngr/libudpechoserver.so

# libeasy
RUN git clone https://dev.iopsys.eu/iopsys/libeasy.git /opt/dev/libeasy
WORKDIR /opt/dev/libeasy
RUN make
RUN mkdir -p /usr/include/easy
RUN cp -a libeasy*.so* /usr/lib
RUN cp -a *.h /usr/include/easy/

# libethernet
RUN git clone https://dev.iopsys.eu/iopsys/libethernet.git /opt/dev/libethernet
WORKDIR /opt/dev/libethernet
RUN make
RUN cp ethernet.h /usr/include
RUN cp -a libethernet*.so* /usr/lib
RUN ldconfig

# libqos
RUN git clone https://dev.iopsys.eu/hal/libqos.git /opt/dev/libqos
WORKDIR /opt/dev/libqos
RUN make
RUN mkdir -p /usr/include/
RUN cp -a libqos*.so* /usr/lib/
RUN cp -a include/*.h /usr/include/

# ethmngr
RUN git clone https://dev.iopsys.eu/hal/ethmngr.git /opt/dev/ethmngr
WORKDIR /opt/dev/ethmngr
RUN make -C .
RUN cp -f ./ethmngr /usr/sbin/ethmngr

# timemngr
RUN git clone https://dev.iopsys.eu/bbf/timemngr.git /opt/dev/timemngr
WORKDIR /opt/dev/timemngr
RUN make -C ./src/ clean && make -C ./src/
RUN cp -a ./src/*.so* /usr/lib/
RUN cp -f ./src/timemngr /usr/sbin/timemngr

## copy bbfdm test files
WORKDIR /opt/dev/bbfdm
RUN cp -r ./test/files/etc/* /etc/
RUN cp -r ./test/files/usr/* /usr/
RUN cp -r ./test/files/var/* /var/
RUN cp -r ./test/files/tmp/* /tmp/
RUN cp -r ./test/files/lib/* /lib/

# icwmp
RUN git clone https://dev.iopsys.eu/bbf/icwmp.git /opt/dev/icwmp
WORKDIR /opt/dev/icwmp/build
RUN cmake .. -DBBF_VENDOR_PREFIX="X_IOWRT_EU_" -DCMAKE_C_FLAGS="-DICWMP_ENABLE_VENDOR_EXTN" -DCMAKE_INSTALL_PREFIX=/ && make
RUN cp src/icwmpd ../src/
RUN cp bbf_plugin/libcwmpdm.so ../bbf_plugin/
RUN make install
RUN ln -s ../bbf_plugin/libcwmpdm.so /usr/share/bbfdm/micro_services/icwmp.so
RUN cp -rf ../test/files/* /


COPY ./etc /etc
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 7547

# Default command
ENTRYPOINT ["/entrypoint.sh"]