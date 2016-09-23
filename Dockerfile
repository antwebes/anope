FROM ubuntu:14.04
MAINTAINER Borja Maceira <ant@antweb.es>
ENV REFRESHED_AT 2016-09-22
ENV VERSION 0.0.1
ENV DEBIAN_FRONTEND noninteractive
ENV ANOPE_VERSION 2.0.4 


RUN apt-get update && \
    apt-get install -y build-essential curl libgnutls-dev libssl-dev ca-certificates cmake libpcre3-dev libmysqlclient-dev mysql-client unzip wget gettext --no-install-recommends

 RUN useradd -u 10000 -d /anope/ anope && \
    gpasswd -a anope irc  && \
    curl -s --location https://github.com/anope/anope/releases/download/$ANOPE_VERSION/anope-$ANOPE_VERSION-source.tar.gz | tar xz

RUN mkdir -p /src  && \
    mv anope-$ANOPE_VERSION-source /src/anope && \
    cd /src/anope/ && \    
    mv modules/extra/m_mysql.cpp modules/ && \
    mv modules/extra/m_sql_oper.cpp modules/ && \
    mv modules/extra/m_ssl_openssl.cpp modules/ && \
    mv modules/extra/m_ssl_gnutls.cpp modules/ && \
    ln -s modules/extra/stats/  modules/stats && \
    mkdir build && \    
    cd build && \
    cmake -Wall \
      -DINSTDIR:STRING=/anope \
      -DDEFUMASK:STRING=077  \
      -DCMAKE_BUILD_TYPE:STRING=RELEASE \
      -DUSE_RUN_CC_PL:BOOLEAN=ON \
      -DUSE_PCH:BOOLEAN=ON .. && \
    make && \
    make install && \
    apt-get -y remove build-essential cmake && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

ADD conf/limits.conf /etc/security/limits.d/anope.conf
ADD conf/services.conf  /anope/conf/services.conf
ADD conf/services.motd  /anope/conf/services.motd

RUN chown anope:irc -Rfv /anope  && \
    chmod 754 -Rfv /anope

VOLUME ["/anope/logs", "/anope/conf"]

WORKDIR /anope

ENTRYPOINT ["/anope/bin/services","--nofork", "--localedir=/anope/locale"]

CMD [""]

EXPOSE 8000 8888
