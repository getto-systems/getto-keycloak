#!/bin/bash

$APP_ROOT/keycloak/bin/standalone.sh \
  -b 0.0.0.0 \
  --server-config=standalone-ha.xml \
  -Djava.security.egd=file:/dev/urandom \
  -Djavax.net.ssl.trustStore=$APP_ROOT/tmp/ssl/truststore \
  -Djavax.net.ssl.trustStorePassword=MySQLCACertPass \
  -Djavax.net.ssl.keyStore=$APP_ROOT/tmp/ssl/keystore \
  -Djavax.net.ssl.keyStorePassword=mysqlclientpass \
  -Dsystems.getto.keycloak.mysql.connectionurl="jdbc:mysql://$DEV_DB/keycloak_dev?useSSL=true" \
;
