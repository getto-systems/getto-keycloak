FROM buildpack-deps:stretch as builder

ENV KEYCLOAK_VERSION=4.7.0.Final
ENV MYSQL_VERSION=8.0.13

COPY signature /opt

WORKDIR /opt

RUN set -x && \
    curl -L https://downloads.jboss.org/keycloak/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz --output keycloak-4.7.0.Final.tar.gz && \
    sha1sum -c sha1/keycloak-${KEYCLOAK_VERSION}.tar.gz.sha1 && \
    tar xzf keycloak-${KEYCLOAK_VERSION}.tar.gz && \
    mv keycloak-${KEYCLOAK_VERSION} keycloak && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_VERSION}.tar.gz --output mysql-connector-java-8.0.13.tar.gz && \
    md5sum -c md5/mysql-connector-java-${MYSQL_VERSION}.tar.gz.md5 && \
    tar xzf mysql-connector-java-${MYSQL_VERSION}.tar.gz && \
    mv mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar mysql-connector-java.jar && \
    :

FROM openjdk:8-jdk-slim-stretch

COPY --from=builder /opt/keycloak /opt/keycloak
COPY keycloak/standalone/configuration/standalone-ha.xml /opt/keycloak/standalone/configuration/standalone-ha.xml
COPY keycloak/modules/system/layers/keycloak/com/mysql /opt/keycloak/modules/system/layers/keycloak/com/mysql
COPY --from=builder /opt/mysql-connector-java.jar /opt/keycloak/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java.jar

CMD ["/opt/keycloak/bin/standalone.sh", "-b", "0.0.0.0", "--server-config=standalone-ha.xml", "-Djava.security.egd=file:/dev/urandom", "-Dsystems.getto.keycloak.mysql.connectionurl='jdbc:mysql://localhost:3306/keycloak?useSSL=false'", "-Dsystems.getto.keycloak.mysql.username=$DEV_DB_USERNAME", "-Dsystems.getto.keycloak.mysql.password=$DEV_DB_PASSWORD"]
