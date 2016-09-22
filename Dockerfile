FROM ubuntu:16.10
MAINTAINER Borja Maceira <ant@antweb.es>
ENV REFRESHED_AT 2016-09-22
ENV VERSION 0.0.1
ENV DEBIAN_FRONTEND noninteractive 


RUN apt-get update && apt-get install -y -o Dpkg::Options::="--force-confdef" \
    build-essential \
    libssl-dev \
    libmysqlclient-dev \    
    cmake \
    make \
    unzip \
    curl \
    gettext \
    --no-install-recommends && \
    useradd -u 10000 -d /anope/ anope && \
    gpasswd -a anope irc  && \
    curl -s --location https://github.com/anope/anope/archive/2.0.4.zip && \
    unzip 2.0.4.zip && \ 
    rm /2.0.4.zip && \ 
    mv /anope-2.0.4 /src/anope && \
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
    make install
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
