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

##Mise à jour du schéma SQL (10/06/2026)

Les scripts SQL ont été entièrement révisés pour répondre aux exigences de confidentialité et de professionnalisme.  
**Fichiers concernés** : `backend/database/00_reset.sql`, `01_schema.sql`, `02_seed.sql`.

### Principales améliorations
- Ajout des tables `permission` (gestion fine des droits par rôle) et `log_acces` (traçabilité des accès).
- Définition de la visibilité des attributs (`+` public, `-` privé, `~` package) directement dans les commentaires SQL.
- Création de vues dédiées : `vue_patiente_public` (pour la patiente, sans données sensibles) et `vue_soignant_restreint` (pour le personnel non médecin).
- Trigger d’alerte automatique en cas d’hypertension (détection des tensions systolique ≥ 140 ou diastolique ≥ 90).
- Index de performance ajoutés.
- Données de seed enrichies avec des permissions de base (sage-femme, gynécologue, pédiatre, infirmier).

**Les fichiers déposés sont les versions finales et fonctionnelles.**  
Pour appliquer les modifications sur une base existante, exécutez d’abord `00_reset.sql` (supprime toutes les données), puis `01_schema.sql` et `02_seed.sql`.