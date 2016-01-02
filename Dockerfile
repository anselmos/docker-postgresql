FROM hypriot/rpi-node
MAINTAINER sameer@damagehead.com

ENV PG_APP_HOME="/etc/docker-postgresql"\
    PG_VERSION=9.3 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

RUN echo "deb-src http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list \
 && wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \
 && sudo apt-get -y update \
 && sudo apt-get -y upgrade \
 && sudo apt-get -y install build-essential fakeroot \
 && sudo apt-get -y build-dep postgresql-9.4 \
 && sudo apt-get -y build-dep postgresql-common \
 && sudo apt-get -y build-dep postgresql-client-common \
 && sudo apt-get -y build-dep pgdg-keyring

RUN cd /tmp \
 && apt-get source --compile postgresql-common \
 && apt-get source --compile postgresql-client-common \
 && apt-get source --compile pgdg-keyring

RUN cd /tmp \
&& apt-get source --compile postgresql-9.4 

# RUN sudo mkdir /var/local/repository \
#  && echo "deb [ trusted=yes ] file:///var/local/repository ./" | sudo tee /etc/apt/sources.list.d/my_own_repo.list \
#  && cd /var/local/repository \
#  && sudo mv /tmp/*.deb . \
#  && dpkg-scanpackages ./ | sudo tee Packages > /dev/null && sudo gzip -f Packages 


# RUN sudo apt-get update \
# && sudo apt-get install postgresql-9.4


RUN sudo postgresql --help
RUN sudo postgresql version

COPY runtime/ ${PG_APP_HOME}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "${PG_RUNDIR}"]
WORKDIR ${PG_HOME}
ENTRYPOINT ["/sbin/entrypoint.sh"]
