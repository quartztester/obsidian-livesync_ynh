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
	echo "
couchdb couchdb/mode select standalone
couchdb couchdb/mode seen true
couchdb couchdb/bindaddress string 127.0.0.1
couchdb couchdb/bindaddress seen true
couchdb couchdb/cookie string $password
couchdb couchdb/adminpass password $password
couchdb couchdb/adminpass seen true
couchdb couchdb/adminpass_again password $password
couchdb couchdb/adminpass_again seen true" | debconf-set-selections
}

# The deb's unit runs as the system 'couchdb' user, so the data and log
# dirs written through our ini must belong to it, not to $app.
fix_couchdb_ownership() {
	mkdir -p /var/log/$app "$data_dir"
	chown -R couchdb:couchdb /var/log/$app "$data_dir"
	chmod 750 /var/log/$app "$data_dir"
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
