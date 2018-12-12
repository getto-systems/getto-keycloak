#!/bin/bash

/opt/keycloak/bin/standalone.sh \
    -b 0.0.0.0 \
    --server-config=standalone-ha.xml \
    -Djava.security.egd=file:/dev/urandom \
    -Djboss.tx.node.id=node$((RANDOM)) \
    -Djboss.node.name=node$((RANDOM)) \
    -Dsystems.getto.keycloak.mysql.connectionurl='jdbc:mysql://localhost:3306/keycloak?useSSL=false' \
    -Dsystems.getto.keycloak.jbossclustering.connectionurl='jdbc:mysql://localhost:3306/jbossclustering?useSSL=false' \
;
