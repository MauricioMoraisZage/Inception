#!/bin/sh
set -e

PORTDB="${MYSQL_PORT:-3306}"
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASS_ROOT="$(cat /run/secrets/db_root_password)"
DB_PASS_USER="$(cat /run/secrets/db_password)"

#Def: dir de dados do MariaDB, Socket e file de flag pra indicar se houve init.
DATA_DIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
INIT_FLAG="${DATA_DIR}/.db_initialized"

#Cria o dir do socket e garante permissões pra o utilizador mysql.
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Se o file de flag existir, apenas exec a base, ja foi criada.
if [ -f "$INIT_FLAG" ]; then
	exec mariadbd --user=mysql --bind-address=0.0.0.0 --port="${PORTDB}"
fi

echo "[mariadb] First initialization..."
mysql_install_db --user=mysql --datadir="$DATA_DIR" > /dev/null

#Inicia a MariaDB em modo temporario, sem rede, pra conf a DB e o user...
mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking --socket="$SOCKET" &
pid="$!"

RETRY=0
#Espera MariaDB estar pronto, (sem loop) pra evitar travar o init se houver erro.
until mysqladmin ping --socket="$SOCKET" --silent
do
	RETRY=$((RETRY + 1))
	if [ "$RETRY" -ge 30 ]; then
		echo "[mariadb] MariaDB didn’t become ready in time."
		exit 1
	fi
	sleep 1
done

# Config a DB, o user e as permissões necessárias pra o WordPress.
mysql --protocol=socket --socket="$SOCKET" -u root <<-SQL
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASS_ROOT}';
	CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
	CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS_USER}';
	GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
	FLUSH PRIVILEGES;
SQL

# 	Encerra o MariaDB temporario e aguarda o processo terminar...
mysqladmin --protocol=socket --socket="$SOCKET" -u root shutdown \
	|| mysqladmin --protocol=socket --socket="$SOCKET" -u root -p"${DB_PASS_ROOT}" shutdown
wait "$pid"

#Cria flag de inicialização e ajusta.
touch "$INIT_FLAG"
chown mysql:mysql "$INIT_FLAG"

#Init normalmente a MariaDB visto q as configs iniciais foram feita.
echo "[mariadb] Init done!"
exec mariadbd --user=mysql --bind-address=0.0.0.0 --port="${PORTDB}"