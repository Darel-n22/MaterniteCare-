--  MaternitéCare — Schéma PostgreSQL v1.0
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

--  TYPES ÉNUMÉRÉS (ENUM)

CREATE TYPE type_workspace      AS ENUM ('consultations_prenatales', 'bloc_obstetrical', 'post_partum', 'pediatrie');
CREATE TYPE role_personnel      AS ENUM ('sage_femme', 'gyneco_obstetricien', 'pediatre', 'infirmier', 'admin');
CREATE TYPE groupe_sanguin_type AS ENUM ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-');
CREATE TYPE type_grossesse      AS ENUM ('simple', 'gemellaire', 'triple');
CREATE TYPE niveau_risque_type  AS ENUM ('normal', 'modere', 'eleve');
-- normal = gris | modere = orange | eleve = rouge (cahier des charges §3)
CREATE TYPE statut_grossesse    AS ENUM ('en_cours', 'terminee', 'fausse_couche');
CREATE TYPE statut_admission    AS ENUM ('travail_actif', 'observation', 'post_partum_stable', 'sortie_autorisee');
-- travail_actif = ROUGE | observation = BLEU | post_partum_stable/sortie = VERT
CREATE TYPE type_lit            AS ENUM ('travail', 'accouchement', 'observation', 'post_partum');
CREATE TYPE type_rdv            AS ENUM ('consultation_prenatale', 'echographie', 'bilan_sanguin', 'vaccination', 'suivi_post_partum');
CREATE TYPE statut_rdv          AS ENUM ('planifie', 'effectue', 'annule', 'reporte');
CREATE TYPE type_document       AS ENUM ('echographie', 'bilan_sanguin', 'ordonnance', 'compte_rendu', 'autre');
CREATE TYPE type_accouchement   AS ENUM ('voie_basse', 'cesarienne', 'voie_basse_instrumentale');
CREATE TYPE sexe_type           AS ENUM ('masculin', 'feminin', 'indetermine');
CREATE TYPE etat_sante_nne      AS ENUM ('bon', 'surveillance', 'soins_intensifs');



--  TABLE : workspaces  (Unités / Services médicaux)
CREATE TABLE workspaces (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nom         VARCHAR(100) NOT NULL,
    type        type_workspace NOT NULL,
    description TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE workspaces IS 'Unités médicales : consultations, bloc, post-partum, pédiatrie';


--  TABLE : personnel_soignant
CREATE TABLE personnel_soignant (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id     UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    nom              VARCHAR(80) NOT NULL,
    prenom           VARCHAR(80) NOT NULL,
    email            VARCHAR(150) NOT NULL UNIQUE,
    mot_de_passe_hash VARCHAR(255) NOT NULL,  -- bcrypt
    role             role_personnel NOT NULL,
    telephone        VARCHAR(20),
    est_actif        BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE personnel_soignant IS 'Médecins, sages-femmes, infirmiers autorisés';
COMMENT ON COLUMN personnel_soignant.mot_de_passe_hash IS 'Hash bcrypt — jamais stocker en clair';


--  TABLE : tokens_session  (Authentification JWT-like)
CREATE TABLE tokens_session (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    personnel_id UUID        NOT NULL REFERENCES personnel_soignant(id) ON DELETE CASCADE,
    token_hash   VARCHAR(255) NOT NULL UNIQUE,  -- SHA-256 du token
    expire_a     TIMESTAMP   NOT NULL,
    ip_address   VARCHAR(45),  -- IPv4 ou IPv6
    created_at   TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tokens_hash       ON tokens_session(token_hash);
CREATE INDEX idx_tokens_personnel  ON tokens_session(personnel_id);


--  TABLE : lits
CREATE TABLE lits (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id   UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    numero_lit     VARCHAR(10) NOT NULL,
    type_lit       type_lit    NOT NULL,
    est_disponible BOOLEAN     NOT NULL DEFAULT TRUE,
    notes          TEXT,
    created_at     TIMESTAMP   NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, numero_lit)
);

COMMENT ON TABLE lits IS 'Gestion des lits par unité médicale';

--  TABLE : patientes
CREATE TABLE patientes (
    id                        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_dossier            VARCHAR(20) NOT NULL UNIQUE,  -- ex: MAT-2026-001
    nom                       VARCHAR(80) NOT NULL,
    prenom                    VARCHAR(80) NOT NULL,
    date_naissance            DATE        NOT NULL,
    telephone                 VARCHAR(20),
    adresse                   TEXT,
    quartier                  VARCHAR(80),  -- Tie-Tie, Mpaka, Lumumba...
    groupe_sanguin            groupe_sanguin_type,
    date_premiere_consultation DATE,
    antecedents_medicaux      TEXT,
    antecedents_obstetricaux  TEXT,  -- parité, gestes, gestité
    allergies                 TEXT,
    mot_de_passe_hash         VARCHAR(255),  -- pour portail patient
    est_active                BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at                TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE patientes IS 'Dossier identitaire des futures mamans';
COMMENT ON COLUMN patientes.numero_dossier IS 'Code unique généré à la création — partagé avec la patiente pour accès portail';
COMMENT ON COLUMN patientes.quartier IS 'Quartier de Pointe-Noire : Tie-Tie, Mpaka, Lumumba, Matendé, Vindoulou...';

CREATE INDEX idx_patientes_nom           ON patientes(nom, prenom);
CREATE INDEX idx_patientes_dossier       ON patientes(numero_dossier);
CREATE INDEX idx_patientes_quartier      ON patientes(quartier);


--  TABLE : grossesses
CREATE TABLE grossesses (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id             UUID        NOT NULL REFERENCES patientes(id) ON DELETE RESTRICT,
    date_debut_grossesse    DATE,
    date_accouchement_prevu DATE,          -- DDT calculée
    terme_actuel_sa         INTEGER     CHECK (terme_actuel_sa BETWEEN 4 AND 45),  -- semaines d'aménorrhée
    type_grossesse          type_grossesse NOT NULL DEFAULT 'simple',
    niveau_risque           niveau_risque_type NOT NULL DEFAULT 'normal',
    pathologies_actives     TEXT,          -- pré-éclampsie, diabète gestationnel, placenta prævia...
    statut                  statut_grossesse NOT NULL DEFAULT 'en_cours',
    created_at              TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE grossesses IS 'Suivi de chaque grossesse : une patiente peut avoir plusieurs grossesses';
COMMENT ON COLUMN grossesses.niveau_risque IS 'normal=gris, modere=orange, eleve=rouge (code couleur §3 du CDC)';
COMMENT ON COLUMN grossesses.terme_actuel_sa IS 'Semaines aménorrhées actuelles — mis à jour à chaque consultation';

CREATE INDEX idx_grossesses_patiente    ON grossesses(patiente_id);
CREATE INDEX idx_grossesses_risque      ON grossesses(niveau_risque);
CREATE INDEX idx_grossesses_statut      ON grossesses(statut);

CREATE TABLE admissions (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id           UUID        NOT NULL REFERENCES patientes(id) ON DELETE RESTRICT,
    grossesse_id          UUID        REFERENCES grossesses(id) ON DELETE SET NULL,
    workspace_id          UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    lit_id                UUID        REFERENCES lits(id) ON DELETE SET NULL,
    personnel_referent_id UUID        REFERENCES personnel_soignant(id) ON DELETE SET NULL,
    date_admission        TIMESTAMP   NOT NULL DEFAULT NOW(),
    date_sortie           TIMESTAMP,
    statut                statut_admission NOT NULL DEFAULT 'observation',
    motif_admission       TEXT        NOT NULL,
    notes_cliniques       TEXT,
    est_signale           BOOLEAN     NOT NULL DEFAULT FALSE,  -- marqué "drapeau rouge" par soignant
    created_at            TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE admissions IS 'Séjours hospitaliers — lie patiente, lit, workspace et soignant référent';
COMMENT ON COLUMN admissions.statut IS 'travail_actif=ROUGE | observation=BLEU | post_partum_stable/sortie=VERT';
COMMENT ON COLUMN admissions.est_signale IS 'Dossier chaud / prioritaire — mémorisé aussi en localStorage côté frontend';

CREATE INDEX idx_admissions_patiente     ON admissions(patiente_id);
CREATE INDEX idx_admissions_workspace    ON admissions(workspace_id);
CREATE INDEX idx_admissions_statut       ON admissions(statut);
CREATE INDEX idx_admissions_signale      ON admissions(est_signale);

--  TABLE : constantes_vitales  (Partogramme + monitoring)
CREATE TABLE constantes_vitales (
    id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    admission_id            UUID        NOT NULL REFERENCES admissions(id) ON DELETE CASCADE,
    personnel_id            UUID        REFERENCES personnel_soignant(id) ON DELETE SET NULL,
    date_mesure             TIMESTAMP   NOT NULL DEFAULT NOW(),
    tension_sys             INTEGER     CHECK (tension_sys BETWEEN 50 AND 250),   -- mmHg systolique
    tension_dia             INTEGER     CHECK (tension_dia BETWEEN 30 AND 150),   -- mmHg diastolique
    frequence_cardiaque     INTEGER     CHECK (frequence_cardiaque BETWEEN 30 AND 220),  -- bpm
    temperature             DECIMAL(4,1) CHECK (temperature BETWEEN 34.0 AND 43.0),  -- °C
    frequence_respiratoire  INTEGER     CHECK (frequence_respiratoire BETWEEN 8 AND 60),
    spo2                    INTEGER     CHECK (spo2 BETWEEN 50 AND 100),   -- % saturation O2
    dilatation_col_cm       INTEGER     CHECK (dilatation_col_cm BETWEEN 0 AND 10),  -- pour partogramme
    notes                   TEXT,
    created_at              TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE constantes_vitales IS 'Relevés réguliers — constitue le partogramme numérique';
COMMENT ON COLUMN constantes_vitales.tension_sys IS 'Alerte pré-éclampsie si ≥ 140 mmHg systolique';
COMMENT ON COLUMN constantes_vitales.dilatation_col_cm IS '0 = col fermé, 10 = dilatation complète (accouchement imminent)';

CREATE INDEX idx_constantes_admission   ON constantes_vitales(admission_id);
CREATE INDEX idx_constantes_date        ON constantes_vitales(date_mesure);


--  TABLE : rendez_vous
CREATE TABLE rendez_vous (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id    UUID        NOT NULL REFERENCES patientes(id) ON DELETE RESTRICT,
    grossesse_id   UUID        REFERENCES grossesses(id) ON DELETE SET NULL,
    personnel_id   UUID        REFERENCES personnel_soignant(id) ON DELETE SET NULL,
    workspace_id   UUID        NOT NULL REFERENCES workspaces(id) ON DELETE RESTRICT,
    date_rdv       TIMESTAMP   NOT NULL,
    type_rdv       type_rdv    NOT NULL,
    statut         statut_rdv  NOT NULL DEFAULT 'planifie',
    notes          TEXT,
    rappel_envoye  BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_rdv_patiente    ON rendez_vous(patiente_id);
CREATE INDEX idx_rdv_date        ON rendez_vous(date_rdv);
CREATE INDEX idx_rdv_statut      ON rendez_vous(statut);



--  TABLE : examens_documents  (Pièces jointes médicales)
CREATE TABLE examens_documents (
    id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id         UUID        NOT NULL REFERENCES patientes(id) ON DELETE RESTRICT,
    grossesse_id        UUID        REFERENCES grossesses(id) ON DELETE SET NULL,
    rendez_vous_id      UUID        REFERENCES rendez_vous(id) ON DELETE SET NULL,
    personnel_id        UUID        REFERENCES personnel_soignant(id) ON DELETE SET NULL,
    type_document       type_document NOT NULL,
    titre               VARCHAR(200) NOT NULL,
    chemin_fichier      VARCHAR(500),   -- chemin sécurisé côté serveur (jamais exposé directement)
    type_mime           VARCHAR(50) CHECK (type_mime IN ('image/jpeg', 'image/png', 'application/pdf')),
    taille_octets       INTEGER     CHECK (taille_octets > 0),
    date_upload         TIMESTAMP   NOT NULL DEFAULT NOW(),
    upload_par_patiente BOOLEAN     NOT NULL DEFAULT FALSE,
    est_valide          BOOLEAN     NOT NULL DEFAULT FALSE,  -- mis à TRUE après vérif MIME backend
    notes               TEXT,
    created_at          TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE examens_documents IS 'Documents médicaux : échographies, bilans, ordonnances';
COMMENT ON COLUMN examens_documents.type_mime IS 'Seuls JPEG, PNG et PDF acceptés (sécurité §4.2 du CDC)';
COMMENT ON COLUMN examens_documents.est_valide IS 'Validation côté backend obligatoire avant affichage';

CREATE INDEX idx_docs_patiente   ON examens_documents(patiente_id);
CREATE INDEX idx_docs_type       ON examens_documents(type_document);



--  TABLE : vaccinations
CREATE TABLE vaccinations (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id    UUID        NOT NULL REFERENCES patientes(id) ON DELETE RESTRICT,
    grossesse_id   UUID        REFERENCES grossesses(id) ON DELETE SET NULL,
    personnel_id   UUID        REFERENCES personnel_soignant(id) ON DELETE SET NULL,
    type_vaccin    VARCHAR(100) NOT NULL,   -- ex: Tétanos, Hépatite B
    date_vaccination DATE      NOT NULL,
    dose           VARCHAR(50),            -- 1ère dose, rappel, dose unique
    numero_lot     VARCHAR(50),            -- CRITIQUE : recherche sérielle §5 module 3
    prochain_rappel DATE,
    created_at     TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE vaccinations IS 'Carnet vaccinal — numéro de lot permet la corrélation sérielle (module 3 du CDC)';
COMMENT ON COLUMN vaccinations.numero_lot IS 'Clé de recherche pour identifier toutes patientes d un même lot (alerte sanitaire)';

CREATE INDEX idx_vaccins_patiente     ON vaccinations(patiente_id);
CREATE INDEX idx_vaccins_lot          ON vaccinations(numero_lot);  -- CRITIQUE pour recherche corrélée


--  TABLE : accouchements
CREATE TABLE accouchements (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    admission_id             UUID        NOT NULL REFERENCES admissions(id) ON DELETE RESTRICT,
    grossesse_id             UUID        NOT NULL REFERENCES grossesses(id) ON DELETE RESTRICT,
    personnel_responsable_id UUID        REFERENCES personnel_soignant(id) ON DELETE SET NULL,
    date_heure_accouchement  TIMESTAMP   NOT NULL,
    type_accouchement        type_accouchement NOT NULL,
    duree_travail_minutes    INTEGER     CHECK (duree_travail_minutes > 0),
    complications            TEXT,
    notes_postpartum         TEXT,
    created_at               TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE accouchements IS 'Fiche d accouchement — centrale pour les statistiques obstétriques';


--  TABLE : nouveau_nes
CREATE TABLE nouveau_nes (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    accouchement_id       UUID        NOT NULL REFERENCES accouchements(id) ON DELETE RESTRICT,
    mere_id               UUID        NOT NULL REFERENCES patientes(id) ON DELETE RESTRICT,
    date_heure_naissance  TIMESTAMP   NOT NULL,
    sexe                  sexe_type   NOT NULL,
    poids_naissance_g     INTEGER     CHECK (poids_naissance_g BETWEEN 300 AND 7000),  -- grammes
    taille_naissance_cm   DECIMAL(4,1) CHECK (taille_naissance_cm BETWEEN 20.0 AND 70.0),
    perimetre_cranien_cm  DECIMAL(4,1) CHECK (perimetre_cranien_cm BETWEEN 20.0 AND 45.0),
    score_apgar_1min      INTEGER     CHECK (score_apgar_1min BETWEEN 0 AND 10),
    score_apgar_5min      INTEGER     CHECK (score_apgar_5min BETWEEN 0 AND 10),
    score_apgar_10min     INTEGER     CHECK (score_apgar_10min BETWEEN 0 AND 10),
    est_gemeau            BOOLEAN     NOT NULL DEFAULT FALSE,
    numero_gemeau         INTEGER     CHECK (numero_gemeau BETWEEN 1 AND 4),
    etat_sante            etat_sante_nne NOT NULL DEFAULT 'bon',
    notes_pediatriques    TEXT,
    created_at            TIMESTAMP   NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE nouveau_nes IS 'Artefact clinique lié strictement au dossier maternel (§4.1 du CDC)';
COMMENT ON COLUMN nouveau_nes.score_apgar_1min IS 'Score Apgar : 7-10 normal | 4-6 dépression légère | 0-3 grave';
COMMENT ON COLUMN nouveau_nes.est_gemeau IS 'Vrai si grossesse gémellaire ou multiple';

CREATE INDEX idx_nne_mere           ON nouveau_nes(mere_id);
CREATE INDEX idx_nne_accouchement   ON nouveau_nes(accouchement_id);
