-- Seed MaterniteCare – données fictives Pointe-Noire

-- Workspaces
INSERT INTO workspace (id_workspace, nom, type, description) VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Secteur Consultations Prénatales', 'consultations_prenatales', 'Suivi ambulatoire'),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'Bloc Obstétrical', 'bloc_obstetrical', 'Salle de naissance'),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'Post-partum', 'post_partum', 'Suites de couches'),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a14', 'Pédiatrie Néonatale', 'pediatrie', 'Soins nouveau-nés');

-- Lits
INSERT INTO lit (id_lit, workspace_id, numero_lit, type_lit, est_disponible) VALUES
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'T-01', 'travail', FALSE),
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'T-02', 'travail', TRUE),
    ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a23', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a13', 'PP-01', 'post_partum', FALSE);

-- Personnel (mots de passe : 'azerty' hashé en bcrypt)
INSERT INTO personnel_soignant (id_personnel, workspace_id, nom, prenom, email, mot_de_passe_hash, role, specialite, numero_ordre, est_actif, date_embauche) VALUES
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'MABIALA', 'Félicité', 'f.mabiala@maternite.cg', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'sage_femme', NULL, NULL, TRUE, '2020-01-01'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a32', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'NZABA', 'Josiane', 'j.nzaba@maternite.cg', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gyneco_obstetricien', 'Obstétrique', '1234', TRUE, '2018-06-01');

-- Patientes (10 exemples ; vous pouvez en ajouter d'autres)
INSERT INTO patiente (id_patiente, numero_dossier, nom, prenom, date_naissance, telephone, quartier, groupe_sanguin, antecedents_obstetricaux, date_premiere_consultation) VALUES
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 'MAT-2026-001', 'NGOMA', 'Astride', '1997-03-15', '+24206123456', 'Tié-Tié', 'O+', 'G2P1', '2026-01-10'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a42', 'MAT-2026-002', 'BOUANGA', 'Rosalie', '1992-07-22', '+24206234567', 'Mpaka', 'A+', 'G1P0', '2026-02-05'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a43', 'MAT-2026-003', 'MFOUTOU', 'Joëlle', '2000-11-08', '+24206345678', 'Lumumba', 'B+', 'G1P0', '2026-02-20'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'MAT-2026-004', 'KIMPOUNI', 'Nadège', '1989-04-30', '+24206456789', 'Voungou', 'B-', 'G3P2', '2026-01-28'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a45', 'MAT-2026-005', 'LOUBOTA', 'Francine', '1985-09-12', '+24206567890', 'Matendé', 'AB+', 'G4P3', '2026-01-15'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a46', 'MAT-2026-006', 'MAVOUNGOU', 'Sylviane', '2001-06-17', '+24206678901', 'Mvou-Mvou', 'O+', 'G1P0', '2026-02-01'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a47', 'MAT-2026-007', 'NGATSONO', 'Béatrice', '1994-01-25', '+24206789012', 'Tié-Tié Centre', 'A-', 'G2P1', '2026-01-20'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a48', 'MAT-2026-008', 'BIBAYA', 'Claudine', '1999-12-03', '+24206890123', 'Mpaka Centre', 'O-', 'G2P1', '2026-02-10'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a49', 'MAT-2026-009', 'NKODIA', 'Geneviève', '1996-08-14', '+24206901234', 'Loandjili', 'B+', 'G2P1', '2025-09-12'),
    ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a50', 'MAT-2026-010', 'MADZOU', 'Patience', '2003-02-28', '+24207012345', 'Ngoyo', 'A+', 'G1P0', '2026-03-01');

-- Grossesses
INSERT INTO grossesse (id_grossesse, patiente_id, date_debut, date_accouchement_prevu, terme_actuel_sa, type_grossesse, niveau_risque, pathologies_actives, statut) VALUES
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a51', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', '2025-10-01', '2026-06-25', 38, 'gemellaire', 'eleve', 'Grossesse gémellaire', 'en_cours'),
    ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a52', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a42', '2025-09-15', '2026-06-22', 37, 'simple', 'eleve', 'HTA chronique', 'en_cours');

-- Admission active
INSERT INTO admission (id_admission, patiente_id, grossesse_id, workspace_id, lit_id, personnel_referent_id, date_admission, motif, statut_admission, est_critique) VALUES
    ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a61', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a51', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a12', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a21', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', NOW(), 'Travail actif gémellaire', 'travail_actif', TRUE);

-- Constante vitale exemple
INSERT INTO constante_vitale (id_constante, admission_id, personnel_id, date_heure, tension_systolique, tension_diastolique, frequence_cardiaque_mere, dilatation_col, contractions_par_10min, frequence_cardiaque_foetale) VALUES
    ('g0eebc99-9c0b-4ef8-bb6d-6bb9bd380a71', 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a61', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', NOW(), 135, 85, 88, 4, 3, 140);

-- Vaccinations avec lot commun (recherche sérielle)
INSERT INTO vaccination (id_vaccination, patiente_id, personnel_id, type_vaccin, date_vaccination, dose, numero_lot, prochain_rappel) VALUES
    ('h0eebc99-9c0b-4ef8-bb6d-6bb9bd380a81', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a43', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'Tétanos', '2026-02-15', '1ère dose', 'LOT-VAT-2026-A12', '2026-03-15'),
    ('h0eebc99-9c0b-4ef8-bb6d-6bb9bd380a82', 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a46', 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'Tétanos', '2026-02-18', '1ère dose', 'LOT-VAT-2026-A12', '2026-03-18');

-- Permissions de base
INSERT INTO permission (role, ressource, action, autorise) VALUES
    ('sage_femme', 'accouchement', 'read', TRUE),
    ('sage_femme', 'accouchement', 'create', TRUE),
    ('sage_femme', 'accouchement', 'voie_basse', TRUE),
    ('sage_femme', 'accouchement', 'cesarienne', FALSE),
    ('gyneco_obstetricien', 'accouchement', 'all', TRUE),
    ('pediatre', 'nouveau_ne', 'all', TRUE),
    ('infirmier', 'constante_vitale', 'create', TRUE);