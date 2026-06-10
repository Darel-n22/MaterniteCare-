-- Schéma MaterniteCare – version finale avec confidentialité
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Types énumérés (publics)
CREATE TYPE type_workspace AS ENUM ('consultations_prenatales', 'bloc_obstetrical', 'post_partum', 'pediatrie');
CREATE TYPE role_personnel AS ENUM ('sage_femme', 'gyneco_obstetricien', 'pediatre', 'infirmier', 'admin');
CREATE TYPE groupe_sanguin AS ENUM ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-');
CREATE TYPE type_grossesse AS ENUM ('simple', 'gemellaire', 'triple');
CREATE TYPE niveau_risque AS ENUM ('normal', 'modere', 'eleve');
CREATE TYPE statut_grossesse AS ENUM ('en_cours', 'terminee', 'fausse_couche');
CREATE TYPE statut_admission AS ENUM ('travail_actif', 'observation', 'post_partum_stable', 'sortie_autorisee');
CREATE TYPE type_lit AS ENUM ('travail', 'accouchement', 'observation', 'post_partum');
CREATE TYPE type_rdv AS ENUM ('consultation_prenatale', 'echographie', 'bilan_sanguin', 'vaccination', 'suivi_post_partum');
CREATE TYPE statut_rdv AS ENUM ('planifie', 'effectue', 'annule', 'reporte');
CREATE TYPE type_document AS ENUM ('echographie', 'bilan_sanguin', 'ordonnance', 'compte_rendu', 'autre');
CREATE TYPE type_accouchement AS ENUM ('voie_basse', 'cesarienne', 'voie_basse_instrumentale');
CREATE TYPE sexe_type AS ENUM ('masculin', 'feminin', 'indetermine');
CREATE TYPE etat_sante_nne AS ENUM ('bon', 'surveillance', 'soins_intensifs');

-- 1. WORKSPACE (unité médicale)
CREATE TABLE workspace (
    id_workspace UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(100) NOT NULL,           -- +
    type type_workspace NOT NULL,        -- +
    description TEXT                     -- +
);

-- 2. PERSONNEL_SOIGNANT
CREATE TABLE personnel_soignant (
    id_personnel UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspace(id_workspace), -- +
    nom VARCHAR(80) NOT NULL,              -- +
    prenom VARCHAR(80) NOT NULL,           -- +
    email VARCHAR(150) UNIQUE NOT NULL,    -- +
    mot_de_passe_hash VARCHAR(255) NOT NULL, -- -
    role role_personnel NOT NULL,          -- +
    specialite VARCHAR(100),               -- -
    numero_ordre VARCHAR(50),              -- -
    est_actif BOOLEAN DEFAULT TRUE,        -- ~
    date_embauche DATE NOT NULL DEFAULT CURRENT_DATE  -- -
);

-- 3. LIT
CREATE TABLE lit (
    id_lit UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES workspace(id_workspace), -- +
    numero_lit VARCHAR(10) NOT NULL,       -- +
    type_lit type_lit NOT NULL,            -- +
    est_disponible BOOLEAN DEFAULT TRUE,   -- ~
    UNIQUE (workspace_id, numero_lit)
);

-- 4. PATIENTE
CREATE TABLE patiente (
    id_patiente UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_dossier VARCHAR(20) UNIQUE NOT NULL,  -- +
    nom VARCHAR(80) NOT NULL,                    -- +
    prenom VARCHAR(80) NOT NULL,                 -- +
    date_naissance DATE NOT NULL,                -- +
    telephone VARCHAR(20),                       -- -
    adresse TEXT,                                -- -
    quartier VARCHAR(80),                        -- +
    groupe_sanguin groupe_sanguin,               -- -
    antecedents_medicaux TEXT,                   -- -
    antecedents_obstetricaux TEXT,               -- -
    allergies TEXT,                              -- -
    date_premiere_consultation DATE,             -- +
    mot_de_passe_hash VARCHAR(255),              -- -
    est_active BOOLEAN DEFAULT TRUE              -- ~
);

-- 5. GROSSESSE
CREATE TABLE grossesse (
    id_grossesse UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    date_debut DATE NOT NULL,                     -- +
    date_accouchement_prevu DATE,                 -- +
    terme_actuel_sa INTEGER CHECK (terme_actuel_sa >= 0), -- +
    type_grossesse type_grossesse DEFAULT 'simple', -- +
    niveau_risque niveau_risque DEFAULT 'normal', -- +
    pathologies_actives TEXT,                     -- -
    statut statut_grossesse DEFAULT 'en_cours'    -- +
);

-- 6. ADMISSION
CREATE TABLE admission (
    id_admission UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    grossesse_id UUID REFERENCES grossesse(id_grossesse),       -- +
    workspace_id UUID NOT NULL REFERENCES workspace(id_workspace), -- +
    lit_id UUID REFERENCES lit(id_lit),                         -- ~
    personnel_referent_id UUID REFERENCES personnel_soignant(id_personnel), -- +
    date_admission TIMESTAMP NOT NULL DEFAULT NOW(), -- +
    date_sortie TIMESTAMP,                            -- +
    motif TEXT NOT NULL,                              -- -
    statut_admission statut_admission NOT NULL,       -- +
    est_critique BOOLEAN DEFAULT FALSE                -- ~
);

-- 7. CONSTANTE_VITALE (partogramme)
CREATE TABLE constante_vitale (
    id_constante UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admission_id UUID NOT NULL REFERENCES admission(id_admission), -- +
    personnel_id UUID REFERENCES personnel_soignant(id_personnel), -- +
    date_heure TIMESTAMP NOT NULL DEFAULT NOW(),   -- +
    tension_systolique INTEGER CHECK (tension_systolique BETWEEN 50 AND 250), -- -
    tension_diastolique INTEGER CHECK (tension_diastolique BETWEEN 30 AND 150), -- -
    frequence_cardiaque_mere INTEGER CHECK (frequence_cardiaque_mere BETWEEN 30 AND 220), -- -
    frequence_respiratoire INTEGER CHECK (frequence_respiratoire BETWEEN 8 AND 60), -- -
    temperature DECIMAL(4,1) CHECK (temperature BETWEEN 34.0 AND 43.0), -- -
    saturation_o2 INTEGER CHECK (saturation_o2 BETWEEN 50 AND 100), -- -
    dilatation_col INTEGER CHECK (dilatation_col BETWEEN 0 AND 10), -- -
    contractions_par_10min INTEGER CHECK (contractions_par_10min >= 0), -- -
    frequence_cardiaque_foetale INTEGER CHECK (frequence_cardiaque_foetale BETWEEN 60 AND 220), -- -
    ocytocine_dose DECIMAL(5,2),                 -- -
    anesthesie_type VARCHAR(50),                 -- -
    notes TEXT                                   -- -
);

-- 8. RENDEZ_VOUS
CREATE TABLE rendez_vous (
    id_rdv UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    grossesse_id UUID REFERENCES grossesse(id_grossesse),       -- +
    personnel_id UUID REFERENCES personnel_soignant(id_personnel), -- +
    workspace_id UUID NOT NULL REFERENCES workspace(id_workspace), -- +
    date_heure TIMESTAMP NOT NULL,                -- +
    type_rdv type_rdv NOT NULL,                   -- +
    statut statut_rdv DEFAULT 'planifie',         -- +
    notes TEXT                                    -- -
);

-- 9. DOCUMENT_MEDICAL
CREATE TABLE document_medical (
    id_document UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    grossesse_id UUID REFERENCES grossesse(id_grossesse),       -- +
    personnel_id UUID REFERENCES personnel_soignant(id_personnel), -- +
    type_document type_document NOT NULL,         -- +
    titre VARCHAR(200) NOT NULL,                  -- +
    chemin_fichier VARCHAR(500) NOT NULL,         -- -
    type_mime VARCHAR(50) CHECK (type_mime IN ('image/jpeg','image/png','application/pdf')), -- +
    taille_octets INTEGER NOT NULL,               -- +
    date_upload TIMESTAMP DEFAULT NOW(),          -- +
    upload_par_patiente BOOLEAN DEFAULT FALSE,    -- +
    est_valide BOOLEAN DEFAULT FALSE              -- +
);

-- 10. VACCINATION
CREATE TABLE vaccination (
    id_vaccination UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    grossesse_id UUID REFERENCES grossesse(id_grossesse),       -- +
    personnel_id UUID REFERENCES personnel_soignant(id_personnel), -- +
    type_vaccin VARCHAR(100) NOT NULL,            -- +
    date_vaccination DATE NOT NULL,               -- +
    dose VARCHAR(50),                             -- +
    numero_lot VARCHAR(50),                       -- ~ (interne)
    prochain_rappel DATE                          -- +
);
CREATE INDEX idx_vaccination_lot ON vaccination(numero_lot);

-- 11. ORDONNANCE
CREATE TABLE ordonnance (
    id_ordonnance UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patiente_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    grossesse_id UUID REFERENCES grossesse(id_grossesse),       -- +
    personnel_id UUID NOT NULL REFERENCES personnel_soignant(id_personnel), -- +
    date_prescription TIMESTAMP DEFAULT NOW(),   -- +
    contenu TEXT NOT NULL,                        -- -
    valide_jusqua DATE                            -- +
);

-- 12. ACCOUCHEMENT
CREATE TABLE accouchement (
    id_accouchement UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admission_id UUID NOT NULL REFERENCES admission(id_admission), -- +
    grossesse_id UUID NOT NULL REFERENCES grossesse(id_grossesse), -- +
    personnel_responsable_id UUID REFERENCES personnel_soignant(id_personnel), -- +
    type_accouchement type_accouchement NOT NULL, -- +
    date_heure_accouchement TIMESTAMP NOT NULL,   -- +
    duree_travail_minutes INTEGER,                -- +
    complications TEXT,                           -- -
    notes_postpartum TEXT                         -- -
);

-- 13. NOUVEAU_NE
CREATE TABLE nouveau_ne (
    id_nouveau_ne UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    accouchement_id UUID NOT NULL REFERENCES accouchement(id_accouchement), -- +
    mere_id UUID NOT NULL REFERENCES patiente(id_patiente), -- +
    sexe sexe_type NOT NULL,                       -- +
    date_heure_naissance TIMESTAMP NOT NULL,       -- +
    poids_grammes INTEGER CHECK (poids_grammes BETWEEN 300 AND 7000), -- +
    taille_cm DECIMAL(4,1),                        -- +
    perimetre_cranien_cm DECIMAL(4,1),             -- +
    apgar_1min INTEGER CHECK (apgar_1min BETWEEN 0 AND 10), -- +
    apgar_5min INTEGER CHECK (apgar_5min BETWEEN 0 AND 10), -- +
    apgar_10min INTEGER CHECK (apgar_10min BETWEEN 0 AND 10), -- +
    est_gemeau BOOLEAN DEFAULT FALSE,              -- +
    numero_gemeau INTEGER,                         -- +
    etat_sante etat_sante_nne DEFAULT 'bon',       -- +
    notes_pediatriques TEXT                        -- -
);

-- 14. PERMISSION (gestion des droits par rôle)
CREATE TABLE permission (
    id_permission UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role role_personnel NOT NULL,       -- -
    ressource VARCHAR(50) NOT NULL,     -- -
    action VARCHAR(20) NOT NULL,        -- -
    autorise BOOLEAN DEFAULT FALSE,     -- -
    UNIQUE(role, ressource, action)
);

-- 15. LOG_ACCES (traçabilité)
CREATE TABLE log_acces (
    id_log UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    personnel_id UUID REFERENCES personnel_soignant(id_personnel), -- -
    patiente_id UUID REFERENCES patiente(id_patiente),            -- -
    date_heure TIMESTAMP DEFAULT NOW(),   -- -
    ip_adresse INET,                      -- -
    action VARCHAR(100) NOT NULL,         -- -
    details TEXT                          -- -
);

-- Index de performance
CREATE INDEX idx_patiente_quartier ON patiente(quartier);
CREATE INDEX idx_patiente_numero_dossier ON patiente(numero_dossier);
CREATE INDEX idx_admission_patiente ON admission(patiente_id);
CREATE INDEX idx_admission_workspace ON admission(workspace_id);
CREATE INDEX idx_admission_statut ON admission(statut_admission);
CREATE INDEX idx_constante_admission ON constante_vitale(admission_id);
CREATE INDEX idx_rdv_patiente ON rendez_vous(patiente_id);
CREATE INDEX idx_document_patiente ON document_medical(patiente_id);
CREATE INDEX idx_log_date ON log_acces(date_heure);

-- Vues pour la confidentialité
-- Vue publique (pour la patiente via son code dossier)
CREATE VIEW vue_patiente_public AS
SELECT 
    id_patiente,
    numero_dossier,
    nom,
    prenom,
    date_naissance,
    quartier,
    date_premiere_consultation
FROM patiente WHERE est_active = true;

-- Vue restreinte pour les soignants (exclut certains champs privés)
CREATE VIEW vue_soignant_restreint AS
SELECT 
    p.id_patiente,
    p.numero_dossier,
    p.nom,
    p.prenom,
    p.date_naissance,
    p.quartier,
    p.date_premiere_consultation,
    p.est_active,
    g.id_grossesse,
    g.terme_actuel_sa,
    g.niveau_risque,
    a.id_admission,
    a.statut_admission,
    a.est_critique
FROM patiente p
LEFT JOIN grossesse g ON g.patiente_id = p.id_patiente AND g.statut = 'en_cours'
LEFT JOIN admission a ON a.patiente_id = p.id_patiente AND a.date_sortie IS NULL;

-- Trigger : alerte hypertension (inscrit dans logs)
CREATE OR REPLACE FUNCTION check_hypertension_alerte()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tension_systolique >= 140 OR NEW.tension_diastolique >= 90 THEN
        INSERT INTO log_acces (personnel_id, patiente_id, action, details)
        SELECT NEW.personnel_id, a.patiente_id, 'ALERTE_HYPERTENSION',
               format('TA %s/%s mmHg', NEW.tension_systolique, NEW.tension_diastolique)
        FROM admission a WHERE a.id_admission = NEW.admission_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_hypertension_alerte
AFTER INSERT ON constante_vitale
FOR EACH ROW EXECUTE FUNCTION check_hypertension_alerte();