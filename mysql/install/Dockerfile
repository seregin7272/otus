FROM mysql:8.0.21

RUN apt-get update && apt-get install -y wget curl lsb-release

RUN wget https://repo.percona.com/apt/percona-release_latest.xenial_all.deb

RUN dpkg -i percona-release_latest.xenial_all.deb

RUN apt-get update && apt-get install -y percona-xtrabackup-80


RUN groupadd --gid 1000 otus \
    && useradd --uid 1000 --gid otus --shell /bin/bash --create-home otus

#USER otus

RUN mkdir -p /backups

RUN chown -R mysql:mysql /var/lib/mysql/