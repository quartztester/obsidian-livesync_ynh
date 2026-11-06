# Connexion depuis Obsidian

Dans le plug-in LiveSync, choisir *Configure a remote manually* → *CouchDB*, puis :

- **CouchDB URI** : `https://votre.domaine/chemin` (l'URL d'installation de cette app)
- **Identifiant / Mot de passe** : les identifiants administrateur CouchDB choisis à l'installation

Le mot de passe administrateur est stocké dans les paramètres de l'app :

```bash
yunohost app setting obsidian-livesync password
```

# Changer le mot de passe administrateur

Modifier la question `password` lors d'une mise à jour met à jour l'administrateur
CouchDB. Pour créer des comptes par utilisateur, utiliser l'API CouchDB (`_users`).

# Localisation des données

Les bases des coffre-vaults sont dans le répertoire de données de l'app
(`/home/yunohost.app/obsidian-livesync` par défaut) et incluses dans les sauvegardes YunoHost.
