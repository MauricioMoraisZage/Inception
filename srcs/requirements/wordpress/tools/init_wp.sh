#!/bin/sh
set -e

NAMEDB="${MYSQL_DATABASE}"
USERDB="${MYSQL_USER}"
PASSDB="$(cat /run/secrets/db_password)"
HOSTDB="mariadb"
PORTDB="${MYSQL_PORT:-3306}"

WP_PATH="/var/www/html"
WP_URL="https://${DOMAIN_NAME:-localhost}"
WPTITLE="${WP_TITLE:-Inception}"

WP_ADM_NAME="${WP_ADMIN_USER:-mamorais}"
WP_ADM_MAIL="${WP_ADMIN_EMAIL:-moldejovethmolde123@gmail.com}"
WP_ADM_PASS="$(cat /run/secrets/wp_admin_password)"

WPN_USER="${WP_USER:-Afroboy}"
WP_USER_MAIL="${WP_USER_EMAIL:-afroboymolde@gmail.com}"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"

#Def cache do WP-CLI em /tmp e ajusta permissões pra evitar erros com www-data
#WP_CLI_CACHE_DIR (onde o wp guarda files temporarios)
export WP_CLI_CACHE_DIR=/tmp/.wp-cli-cache
mkdir -p "$WP_CLI_CACHE_DIR" /var/www/.wp-cli /run/php
chown -R www-data:www-data "$WP_CLI_CACHE_DIR" /var/www/.wp-cli /run/php "$WP_PATH"

#Espera MariaDB ficar disponível
RETRY=0
until mariadb -h"$HOSTDB" -P"$PORTDB" -u"$USERDB" -p"$PASSDB" -e "SELECT 1;" >/dev/null 2>&1
do
	RETRY=$((RETRY + 1))
	if [ "$RETRY" -ge 30 ]; then
		echo "[wordpress] MariaDB not ready after 30 attempts."
		exit 1
	fi
	echo "[wordpress] Waiting for MariaDB... (${RETRY}/30)"
	sleep 2
done

# Instala o WordPress se ainda não estiver instalado
if [ ! -f "$WP_PATH/wp-config.php" ]; then
	echo "[wordpress] Installing WordPress..."
	su -s /bin/sh www-data -c "HOME=/var/www WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR \
		wp core download --path=$WP_PATH"

	su -s /bin/sh www-data -c "HOME=/var/www WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR \
		wp config create --path=$WP_PATH --dbhost=${HOSTDB}:${PORTDB} --dbname=$NAMEDB \
			--dbuser=$USERDB --dbpass=$PASSDB"

	su -s /bin/sh www-data -c "HOME=/var/www WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR \
		wp core install --path=$WP_PATH --url=$WP_URL --title='$WPTITLE' \
			--admin_user=$WP_ADM_NAME --admin_password=$WP_ADM_PASS \
			--admin_email=$WP_ADM_MAIL --skip-email"
	echo "[wordpress] WordPress installed."
fi

#Atualiza as URLs do site e home pra garantir q estão corretas
su -s /bin/sh www-data -c "HOME=/var/www WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR \
	wp option update siteurl $WP_URL --path=$WP_PATH" >/dev/null 2>&1 || true

su -s /bin/sh www-data -c "HOME=/var/www WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR \
	wp option update home $WP_URL --path=$WP_PATH" >/dev/null 2>&1 || true

# Cria usuer adicional se ele não existir
#if ! su -s /bin/sh www-data -c "HOME=/var/www wp user get \"$WPN_USER\" --path=$WP_PATH" >/dev/null 2>&1; then
#	su -s /bin/sh www-data -c "HOME=/var/www WP_CLI_CACHE_DIR=$WP_CLI_CACHE_DIR \
#		wp user create \"$WPN_USER\" \"$WP_USER_MAIL\" \
#			--user_pass=\"$WP_USER_PASS\" --role=subscriber --path=$WP_PATH"
#	echo "[wordpress] User created: $WPN_USER"
#fi

if ! su -s /bin/sh www-data -c \
    "HOME=/var/www WP_CLI_CACHE_DIR=\"$WP_CLI_CACHE_DIR\" \
    wp user get \"$WPN_USER\" --path=\"$WP_PATH\"" \
    >/dev/null 2>&1; then

    su -s /bin/sh www-data -c \
        "HOME=/var/www WP_CLI_CACHE_DIR=\"$WP_CLI_CACHE_DIR\" \
        wp user create \"$WPN_USER\" \"$WP_USER_MAIL\" \
        --user_pass=\"\$(cat /run/secrets/wp_user_password)\" \
        --role=subscriber \
        --path=\"$WP_PATH\""

    echo "[wordpress] User created: $WPN_USER"
fi

echo "[wordpress] Done."
exec "$@"
