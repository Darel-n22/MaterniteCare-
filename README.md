# MaterniteCare – Suivi obstétrical

## État d’avancement (13/06/2026)

### Fonctionnalités réalisées

#### Base de données PostgreSQL

- Base de données `MaterniteCare_DB` opérationnelle.
- Tables pour la gestion des patientes, grossesses, admissions, rendez-vous, vaccinations, documents médicaux et personnel soignant.
- Contraintes, index et clés étrangères configurés.
- Vues SQL pour limiter l'accès aux données sensibles.
- Données de test intégrées.

#### API REST (Node.js / Express)

Routes disponibles :

- `GET /api/health`
- `GET /api/patients`
- `GET /api/patients/:id` (protégée JWT)
- `GET /api/workspaces/:id/patients` (protégée JWT)
- `GET /api/search/lot/:numero_lot` (protégée JWT)
- `POST /api/auth/login` (authentification)
- `POST /api/upload/:codeDossier` (upload patient)
- `POST /api/documents` (upload soignant, protégé JWT)

Fonctionnalités :

- Connexion PostgreSQL fonctionnelle.
- Authentification JWT (login, middleware).
- Upload sécurisé de fichiers (JPEG, PNG, PDF) avec `multer`.
- Vérification du type MIME et stockage dans `uploads/`.

#### Sécurité

- Mots de passe chiffrés avec bcrypt.
- Tokens JWT pour les soignants (expiration 8h).
- Vues SQL de protection des données.
- Table `log_acces` pour la traçabilité.
- Contrôle des fichiers uploadés (type, taille).

---

### Preuve de connexion à PostgreSQL

![Connexion PostgreSQL réussie](./docs/pg_connection.png)

*Interface pgAdmin4 montrant la base `MaterniteCare_DB` et la table `patiente` avec ses données.*

---

### Historique

| Commit   | Description                                     |
| -------- | ----------------------------------------------- |
| Commit 1 | Structure SQL et données initiales              |
| Commit 2 | Sécurité, permissions et traçabilité            |
| Commit 3 | API REST connectée à PostgreSQL                 |
| Commit 4 | Authentification JWT (login, middleware)        |
| Commit 5 | Upload de documents médicaux (multer, routes)   |

---

### État actuel

**Statut :** Base de données terminée, API REST complète (authentification + upload), prête pour le frontend.

**Progression estimée :** 85 %

---

## Structure du projet

```text
MaterniteCare/
├── backend/
│   ├── database/
│   │   ├── 00_reset.sql
│   │   ├── 01_schema.sql
│   │   └── 02_seed.sql
│   ├── uploads/               (dossier pour les fichiers reçus)
│   ├── server.js
│   ├── package.json
│   └── .env.example
│
├── docs/
│   └── pg_connection.png
│
├── frontend/                  (à venir)
│
└── README.md