FROM lolhens/baseimage:latest
MAINTAINER LolHens <pierrekisters@gmail.com>


ARG DB2_VERSION=11.1
ARG DB2_NAME=expc
ARG DB2_FILE=v${DB2_VERSION}_linuxx64_$DB2_NAME.tar.gz
ARG DB2_URL=https://iwm.dhe.ibm.com/sdfdl/v2/regs2/db2pmopn/Express-C/DB2ExpressC11/Xa.2/Xb.aA_60_-i79i02wKeP3yF1M5loEtDOzs5fIfUs0hDe4k/Xc.Express-C/DB2ExpressC11/v11.1_linuxx64_expc.tar.gz/Xd./Xf.LPr.D1vk/Xg.9141390/Xi.swg-db2expressc/XY.regsrvs/XZ.06EaLq6c40xuKZXdd5lkqUJ3lro/v11.1_linuxx64_expc.tar.gz
ENV DB2_HOME /opt/ibm/db2/V$DB2_VERSION


RUN apt-get update \
 && apt-get install -y \
      libxml2 \
      libaio1 \
      libnuma1 \
      sudo

RUN cd "/tmp" \
 && curl -LO $DB2_URL \
 && tar -xf $DB2_FILE \
 && cd $DB2_NAME \
 && OSN="Linux" \
 && OSM="x86_64" \
 && (printf "yes\nyes" | ./db2_install -f sysreq || true) \
 && cd $DB2_HOME \
 && cp /tmp/db2_install.log.* . \
 && chmod +x adm/* \
 && groupadd db2grp1 \
 && groupadd dasadm1 \
 && groupadd db2fgrp1 \
 && useradd -g db2grp1 -G dasadm1 -m db2inst1 \
    #passwd db2inst1
 && useradd -g dasadm1 -G db2grp1 -m dasusr1 \
    #passwd dasusr1
 && useradd -g db2fgrp1 -m db2fenc1 \
    #passwd db2fenc1
 && instance/dascrt -u dasusr1 \
 && instance/db2icrt -u db2fenc1 db2inst1 \
 && sudo -u db2inst1 adm/db2set DB2COMM=tcpip \
 && sudo -u db2inst1 bin/db2 update dbm cfg using SVCENAME 50000 \
 && cleanimage


WORKDIR $DB2_HOME
CMD sudo -u db2inst1 adm/db2start


VOLUME /usr/local/appdata/artifactory

EXPOSE 8081
