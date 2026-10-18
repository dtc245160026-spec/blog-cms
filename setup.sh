#!/usr/bin/env bash
set -e
gen(){ openssl rand -base64 24 | tr -d '=+/'; }

if [ ! -f .env ]; then
cat > .env <<EOF
MYSQL_ROOT_PASSWORD=$(gen)
WP_DB_NAME=wordpress
WP_DB_USER=wpuser
WP_DB_PASSWORD=$(gen)
EXPORTER_PASSWORD=$(gen)
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$(gen)
EOF
fi
set -a; . ./.env; set +a

mkdir -p nginx/certs mysql/init
[ -f nginx/certs/server.crt ] || openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/certs/server.key -out nginx/certs/server.crt -subj "/CN=localhost"
chmod 644 nginx/certs/server.key   # nginx chạy non-root cần đọc được (môi trường lab)

# User giám sát DB (quyền tối thiểu)
cat > mysql/init/02-exporter.sql <<EOF
CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY '${EXPORTER_PASSWORD}' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
EOF
cat > mysql/exporter.my.cnf <<EOF
[client]
user=exporter
password=${EXPORTER_PASSWORD}
host=db
EOF
chmod 644 mysql/exporter.my.cnf
echo "OK. Xem mật khẩu trong file .env"
