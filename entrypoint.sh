#!/bin/bash

/opt/keycloak/bin/standalone.sh \
    -b 0.0.0.0 \
    --server-config=standalone-ha.xml \
    -Djava.security.egd=file:/dev/urandom \
    -Dsystems.getto.keycloak.mysql.connectionurl='jdbc:mysql://localhost:3306/keycloak?useSSL=false' \
    -Dsystems.getto.keycloak.mysql.username=$DB_USERNAME \
    -Dsystems.getto.keycloak.mysql.password=$DB_PASSWORD \
;
