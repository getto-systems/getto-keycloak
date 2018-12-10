FROM buildpack-deps:stretch as builder

COPY signature /opt

WORKDIR /opt

RUN set -x && \
    curl -L https://downloads.jboss.org/keycloak/4.7.0.Final/keycloak-4.7.0.Final.tar.gz --output keycloak-4.7.0.Final.tar.gz && \
    sha1sum -c sha1/keycloak-4.7.0.Final.tar.gz.sha1 && \
    tar xzf keycloak-4.7.0.Final.tar.gz && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.13.tar.gz --output mysql-connector-java-8.0.13.tar.gz && \
    md5sum -c md5/mysql-connector-java-8.0.13.tar.gz.md5 && \
    tar xzf mysql-connector-java-8.0.13.tar.gz && \
    :

FROM openjdk:8-jdk-slim-stretch

COPY --from=builder /opt/keycloak-4.7.0.Final /opt/keycloak
COPY keycloak/4.7.0.Final/standalone/configuration/standalone-ha.xml /opt/keycloak/standalone/configuration/standalone-ha.xml
COPY keycloak/4.7.0.Final/modules/system/layers/keycloak/com/mysql /opt/keycloak/modules/system/layers/keycloak/com/mysql
COPY --from=builder /opt/mysql-connector-java-8.0.13/mysql-connector-java-8.0.13.jar /opt/keycloak/modules/system/layers/keycloak/com/mysql/main/mysql-connector-java-8.0.13.jar

CMD ["/opt/keycloak/bin/standalone.sh", "-b", "0.0.0.0", "--server-config=standalone-ha.xml", "-Djava.security.egd=file:/dev/urandom", "-Dsystems.getto.keycloak.mysql.connectionurl='jdbc:mysql://$DEV_DB/keycloak?useSSL=false'", "-Dsystems.getto.keycloak.mysql.username=$DEV_DB_USERNAME", "-Dsystems.getto.keycloak.mysql.password=$DEV_DB_PASSWORD"]
