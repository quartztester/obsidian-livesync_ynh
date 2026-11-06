#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

COUCHDB_REPO="deb https://apache.jfrog.io/artifactory/couchdb-deb/ $(lsb_release -c -s) main"
COUCHDB_KEY="https://couchdb.apache.org/repo/keys.asc"
log_path="/var/log/$app/couchdb.log"

# Debconf preseed so the CouchDB deb installs non-interactively: standalone
# node, localhost-bound.
seed_couchdb_debconf() {
	debconf-set-selections <<EOF
couchdb couchdb/mode select standalone
couchdb couchdb/mode seen true
couchdb couchdb/bindaddress string 127.0.0.1
couchdb couchdb/bindaddress seen true
couchdb couchdb/cookie string $password
couchdb couchdb/adminpass password $password
couchdb couchdb/adminpass seen true
couchdb couchdb/adminpass_again password $password
couchdb couchdb/adminpass_again seen true
EOF
}

# Run the deb's couchdb unit as $app (matches YunoHost's ownership of
# $install_dir/$data_dir; the deb default user 'couchdb' cannot even exec
# the binary once the install_dir resource owns /opt/couchdb).
fix_couchdb_ownership() {
	mkdir -p "/var/log/$app" "$data_dir" "/etc/systemd/system/couchdb.service.d"
	chown -R "$app:$app" "/var/log/$app" "$data_dir" "$install_dir"
	chmod 750 "/var/log/$app" "$data_dir"
	ynh_config_add --template="systemd_service_dropin.conf" \
		--destination="/etc/systemd/system/couchdb.service.d/$app.conf"
	systemctl daemon-reload
}

# 412 = the database already exists (reinstall/upgrade), which is fine.
create_sync_db() {
	local code
	code=$(curl --silent --output /dev/null --write-out "%{http_code}" \
		--user "admin:$password" -X PUT "http://127.0.0.1:$port/obsidiannotes")
	if [ "$code" != "201" ] && [ "$code" != "412" ]; then
		ynh_die --message="Could not create the sync database (HTTP $code)."
	fi
}
