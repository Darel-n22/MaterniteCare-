# MaterniteCare – Suivi obstétrical

## État d’avancement (12/06/2026)

### Fonctionnalités réalisées

#### Base de données PostgreSQL

* Base de données `MaterniteCare_DB` opérationnelle.
* Tables pour la gestion des patientes, grossesses, admissions, rendez-vous, vaccinations, documents médicaux et personnel soignant.
* Contraintes, index et clés étrangères configurés.
* Vues SQL pour limiter l'accès aux données sensibles.
* Données de test intégrées.

#### API REST (Node.js / Express)

Routes actuellement disponibles :

* `GET /api/health`
* `GET /api/patients`
* `GET /api/patients/:id`
* `GET /api/workspaces/:id/patients`
* `GET /api/search/lot/:numero_lot`

Fonctionnalités :

* Connexion PostgreSQL fonctionnelle.
* Gestion des erreurs.
* Configuration via variables d'environnement.

#### Sécurité

* Mots de passe chiffrés avec bcrypt.
* Vues SQL de protection des données.
* Table `log_acces` pour la traçabilité.
* Préparation du contrôle des fichiers uploadés.

---

### Preuve de connexion à PostgreSQL

![Connexion PostgreSQL réussie](./docs/pg_connection.png)

*Interface pgAdmin4 montrant la base `MaterniteCare_DB` et la table `patiente` avec ses données.*

---

### Historique

| Commit   | Description                          |
| -------- | ------------------------------------ |
| Commit 1 | Structure SQL et données initiales   |
| Commit 2 | Sécurité, permissions et traçabilité |
| Commit 3 | API REST connectée à PostgreSQL      |

---

### État actuel

**Statut :** Base de données terminée et API REST opérationnelle.

**Progression estimée :** 70 %

---

## Structure du projet

```text
MaterniteCare/
├── backend/
│   ├── database/
│   │   ├── 00_reset.sql
│   │   ├── 01_schema.sql
│   │   └── 02_seed.sql
│   ├── server.js
│   ├── package.json
│   └── .env.example
│
├── docs/
│   └── pg_connection.png
│
├── frontend/
│
└── README.md
```
