#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl ca-certificates gnupg

install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs

install -d -m 0755 /opt/app
cat >/opt/app/server.js <<'NODE'
const http = require("http");

const port = Number(process.env.APP_PORT || 3000);
const dbHost = process.env.DB_HOST || "unknown";
const dbName = process.env.DB_NAME || "unknown";

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "content-type": "text/plain" });
    res.end("ok\n");
    return;
  }

  res.writeHead(200, { "content-type": "application/json" });
  res.end(JSON.stringify({
    service: "azure-ha-three-tier-app",
    database: dbName,
    databaseHost: dbHost
  }) + "\n");
});

server.listen(port, "0.0.0.0");
NODE

cat >/opt/app/start.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

identity_endpoint="http://169.254.169.254/metadata/identity/oauth2/token"
resource="https%3A%2F%2Fvault.azure.net"
token_response="$(curl -fsS -H Metadata:true "$${identity_endpoint}?api-version=2018-02-01&resource=$${resource}")"
access_token="$(node -e 'process.stdout.write(JSON.parse(process.argv[1]).access_token)' "$${token_response}")"
secret_response="$(curl -fsS -H "Authorization: Bearer $${access_token}" "https://$${KEY_VAULT_NAME}.vault.azure.net/secrets/$${DB_SECRET_NAME}?api-version=7.4")"
export DB_PASSWORD="$(node -e 'process.stdout.write(JSON.parse(process.argv[1]).value)' "$${secret_response}")"

exec /usr/bin/node /opt/app/server.js
SH

chmod 0750 /opt/app/start.sh

cat >/etc/systemd/system/app.service <<SYSTEMD
[Unit]
Description=Three-tier sample application
After=network-online.target
Wants=network-online.target

[Service]
Environment=APP_PORT=${app_port}
Environment=DB_HOST=${db_host}
Environment=DB_NAME=${db_name}
Environment=DB_USERNAME=${db_username}
Environment=KEY_VAULT_NAME=${key_vault_name}
Environment=DB_SECRET_NAME=${db_secret_name}
ExecStart=/opt/app/start.sh
Restart=always
RestartSec=5
User=root
Group=root

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable app
systemctl restart app
