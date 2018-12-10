FROM buildpack-deps:stretch as builder

ENV KEYCLOAK_VERSION=4.7.0.Final
ENV MYSQL_VERSION=8.0.13

COPY signature /opt

WORKDIR /opt

RUN set -x && \
    curl -L https://downloads.jboss.org/keycloak/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz --output keycloak-4.7.0.Final.tar.gz && \
    sha1sum -c sha1/keycloak-${KEYCLOAK_VERSION}.tar.gz.sha1 && \
    tar xzf keycloak-${KEYCLOAK_VERSION}.tar.gz && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_VERSION}.tar.gz --output mysql-connector-java-8.0.13.tar.gz && \
    md5sum -c md5/mysql-connector-java-${MYSQL_VERSION}.tar.gz.md5 && \
    tar xzf mysql-connector-java-${MYSQL_VERSION}.tar.gz && \
    :

FROM openjdk:8-jdk-slim-stretch

ENV KEYCLOAK_VERSION=4.7.0.Final
ENV MYSQL_VERSION=8.0.13

COPY --from=builder /opt/keycloak-${KEYCLOAK_VERSION} /opt/keycloak
COPY keycloak/${KEYCLOAK_VERSION}/standalone/configuration/standalone-ha.xml /opt/keycloak/standalone/configuration/standalone-ha.xml
COPY keycloak/${KEYCLOAK_VERSION}/modules/system/layers/keycloak/com/mysql /opt/keycloak/modules/system/layers/keycloak/com/mysql
COPY --from=builder /opt/mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar /opt/keycloak/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java-8.0.13.jar

CMD ["/opt/keycloak/bin/standalone.sh", "-b", "0.0.0.0", "--server-config=standalone-ha.xml", "-Djava.security.egd=file:/dev/urandom", "-Dsystems.getto.keycloak.mysql.connectionurl='jdbc:mysql://$DEV_DB/keycloak?useSSL=false'", "-Dsystems.getto.keycloak.mysql.username=$DEV_DB_USERNAME", "-Dsystems.getto.keycloak.mysql.password=$DEV_DB_PASSWORD"]
