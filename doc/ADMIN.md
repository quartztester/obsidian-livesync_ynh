# Connecting Obsidian

In the LiveSync plugin, choose *Configure a remote manually* → *CouchDB*, and set:

- **CouchDB URI**: `https://your.domain/path` (the install URL of this app)
- **Username / Password**: the CouchDB admin credentials chosen at install

The admin password is stored in the app settings and readable with:

```bash
yunohost app setting obsidian-livesync password
```

# Changing the admin password

Changing the `password` question at upgrade time updates the CouchDB admin.
To add per-user accounts instead, use CouchDB's API (the admin can create them
under `_users`; the plugin works with any user allowed on the sync database).

# Data location

Vault databases live in the app's data directory (`/home/yunohost.app/obsidian-livesync`
by default) and are included in YunoHost backups.
