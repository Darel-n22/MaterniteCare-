#  MaternitéCare – API REST & Base PostgreSQL

> Revue intermédiaire – 08 juin 2026  
> Contenu : structure PostgreSQL hospitalière + squelette API REST de gestion des dossiers.

##  Contenu du dépôt

- **Base de données PostgreSQL** : schéma relationnel complet (13 tables, types énumérés, clés étrangères, index)
- **Données de seed** : 20 patientes réalistes (Pointe-Noire, quartiers Tié-Tié, Mpaka, Lumumba…), workspaces, lits, personnel, grossesses, admissions, vaccinations avec numéros de lot
- **API REST (Node.js/Express)** : routes pour la gestion des dossiers patients
- **Diagramme ERD** : visualisation du schéma (`maternitecare.mdj et maternitecare.jpeg `)

##  Installation et lancement

### Prérequis
- PostgreSQL ≥ 14
- Node.js ≥ 18

### 1. Créer la base de données
```bash
createdb maternitecare
psql -U postgres -d maternitecare -f backend/database/01_schema.sql
psql -U postgres -d maternitecare -f backend/database/02_seed.sql