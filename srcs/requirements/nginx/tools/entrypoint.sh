#!/bin/sh
set -e

DOMAIN="${DOMAIN_NAME:-localhost}"

mkdir -p /etc/ssl/private /etc/ssl/certs

#Gera um certificado autoassinado se ainda nao existir.
if [ ! -f /etc/ssl/private/nginx.key ] || [ ! -f /etc/ssl/certs/nginx.crt ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt \
    -subj "/C=AO/ST=Luanda/L=Luanda/O=42/OU=Inception/CN=${DOMAIN}"
fi

exec "$@"
