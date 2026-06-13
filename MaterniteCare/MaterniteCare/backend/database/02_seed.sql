--  MaternitéCare — Données SEED réalistes (v1.0)
--  Contexte : Centre de maternité de Pointe-Noire, Congo
--  20 dossiers patients + personnel + workspaces + lits


--  1. WORKSPACES (Unités médicales)

INSERT INTO workspaces (id, nom, type, description) VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Secteur Consultations Prénatales',   'consultations_prenatales',
   'Suivi ambulatoire des grossesses : pesée, TA, échographies de routine'),

  ('a1000000-0000-0000-0000-000000000002', 'Bloc Obstétrical — Salles de Naissance', 'bloc_obstetrical',
   'Salle de travail, salle d accouchement, salle de réveil post-partum immédiat'),

  ('a1000000-0000-0000-0000-000000000003', 'Unité Post-Partum et Suites de Couches',  'post_partum',
   'Suivi mère-enfant après accouchement : allaitement, soins du nouveau-né, sortie'),

  ('a1000000-0000-0000-0000-000000000004', 'Unité de Pédiatrie Néonatale',  'pediatrie',
   'Soins intensifs néonataux, surveillance des prématurés et nouveau-nés à risque');


--  2. LITS

INSERT INTO lits (workspace_id, numero_lit, type_lit, est_disponible) VALUES
  ('a1000000-0000-0000-0000-000000000002', 'T-01', 'travail',        FALSE),
  ('a1000000-0000-0000-0000-000000000002', 'T-02', 'travail',        FALSE),
  ('a1000000-0000-0000-0000-000000000002', 'T-03', 'travail',        TRUE),
  ('a1000000-0000-0000-0000-000000000002', 'A-01', 'accouchement',   TRUE),
  ('a1000000-0000-0000-0000-000000000002', 'A-02', 'accouchement',   TRUE),
  ('a1000000-0000-0000-0000-000000000002', 'OB-1', 'observation',    FALSE),
  ('a1000000-0000-0000-0000-000000000003', 'PP-01','post_partum',    FALSE),
  ('a1000000-0000-0000-0000-000000000003', 'PP-02','post_partum',    FALSE),
  ('a1000000-0000-0000-0000-000000000003', 'PP-03','post_partum',    TRUE),
  ('a1000000-0000-0000-0000-000000000003', 'PP-04','post_partum',    TRUE);


--  3. PERSONNEL SOIGNANT
--  Mots de passe : "Maternite2026!" hashés (bcrypt, 12 rounds)
INSERT INTO personnel_soignant (id, workspace_id, nom, prenom, email, mot_de_passe_hash, role, telephone) VALUES
  ('b2000000-0000-0000-0000-000000000001',
   'a1000000-0000-0000-0000-000000000002',
   'MABIALA', 'Félicité',
   'f.mabiala@maternitepn.cg',
   '$2b$12$PLACEHOLDER_HASH_MABIALA',
   'sage_femme', '+242 06 501 1001'),

  ('b2000000-0000-0000-0000-000000000002',
   'a1000000-0000-0000-0000-000000000001',
   'NZABA', 'Dr. Josiane',
   'j.nzaba@maternitepn.cg',
   '$2b$12$PLACEHOLDER_HASH_NZABA',
   'gyneco_obstetricien', '+242 06 502 2002'),

  ('b2000000-0000-0000-0000-000000000003',
   'a1000000-0000-0000-0000-000000000004',
   'MOUSSAVOU', 'Dr. Théophile',
   't.moussavou@maternitepn.cg',
   '$2b$12$PLACEHOLDER_HASH_MOUSSAVOU',
   'pediatre', '+242 06 503 3003'),

  ('b2000000-0000-0000-0000-000000000004',
   'a1000000-0000-0000-0000-000000000003',
   'LOUBASSOU', 'Marie-Claire',
   'm.loubassou@maternitepn.cg',
   '$2b$12$PLACEHOLDER_HASH_LOUBASSOU',
   'infirmier', '+242 06 504 4004'),

  ('b2000000-0000-0000-0000-000000000005',
   'a1000000-0000-0000-0000-000000000001',
   'BOUITI', 'Admin',
   'admin@maternitepn.cg',
   '$2b$12$PLACEHOLDER_HASH_ADMIN',
   'admin', '+242 06 500 0000');


--  4. PATIENTES (20 dossiers réalistes — Pointe-Noire)

INSERT INTO patientes (id, numero_dossier, nom, prenom, date_naissance, telephone, quartier,
                       groupe_sanguin, antecedents_obstetricaux, date_premiere_consultation) VALUES

  -- 1 — Grossesse gémellaire, haut risque
  ('c3000000-0000-0000-0000-000000000001',
   'MAT-2026-001', 'NGOMA', 'Astride Pulchérie',
   '1997-03-15', '+242 06 611 0001', 'Tie-Tie',
   'O+', 'G2P1 — 1 accouchement voie basse en 2023, nouveau-né 3100g',
   '2026-01-10'),

  -- 2 — Pré-éclampsie suspectée, urgence potentielle
  ('c3000000-0000-0000-0000-000000000002',
   'MAT-2026-002', 'BOUANGA', 'Rosalie',
   '1992-07-22', '+242 06 611 0002', 'Mpaka',
   'A+', 'G1P0 — primipare, hypertension chronique connue',
   '2026-02-05'),

  -- 3 — Grossesse physiologique simple
  ('c3000000-0000-0000-0000-000000000003',
   'MAT-2026-003', 'MFOUTOU', 'Joëlle Narcisse',
   '2000-11-08', '+242 06 611 0003', 'Lumumba',
   'B+', 'G1P0 — primipare, aucun antécédent notable',
   '2026-02-20'),

  -- 4 — Antécédent de césarienne, risque modéré
  ('c3000000-0000-0000-0000-000000000004',
   'MAT-2026-004', 'KIMPOUNI', 'Nadège',
   '1989-04-30', '+242 06 611 0004', 'Voungou',
   'B-', 'G3P2 — 1 césar en 2019 (dystocie), 1 voie basse en 2021',
   '2026-01-28'),

  -- 5 — Diabète gestationnel, surveillance renforcée
  ('c3000000-0000-0000-0000-000000000005',
   'MAT-2026-005', 'LOUBOTA', 'Francine Amélie',
   '1985-09-12', '+242 06 611 0005', 'Matendé',
   'AB+', 'G4P3 — grande multipare, diabète gestationnel depuis S20',
   '2026-01-15'),

  -- 6 — Grossesse normale, terme proche
  ('c3000000-0000-0000-0000-000000000006',
   'MAT-2026-006', 'MAVOUNGOU', 'Sylviane',
   '2001-06-17', '+242 06 611 0006', 'Mvou-Mvou',
   'O+', 'G1P0 — primipare, suivi régulier, terme prévu dans 2 semaines',
   '2026-02-01'),

  -- 7 — Placenta prævia, haut risque
  ('c3000000-0000-0000-0000-000000000007',
   'MAT-2026-007', 'NGATSONO', 'Béatrice Mireille',
   '1994-01-25', '+242 06 611 0007', 'Tié-Tié Centre',
   'A-', 'G2P1 — placenta prævia diagnostiqué S28, repos strict prescrit',
   '2026-01-20'),

  -- 8 — Grossesse gémellaire, risque modéré
  ('c3000000-0000-0000-0000-000000000008',
   'MAT-2026-008', 'BIBAYA', 'Claudine',
   '1999-12-03', '+242 06 611 0008', 'Mpaka Centre',
   'O-', 'G2P1 — grossesse bichoriale biamniotique, anémie ferriprive',
   '2026-02-10'),

  -- 9 — Post-partum récent, surveillance continue
  ('c3000000-0000-0000-0000-000000000009',
   'MAT-2026-009', 'NKODIA', 'Geneviève',
   '1996-08-14', '+242 06 611 0009', 'Loandjili',
   'B+', 'G2P1 — accouchée hier, voie basse, nouveau-né 3250g, Apgar 9',
   '2025-09-12'),

  -- 10 — Menace d accouchement prématuré
  ('c3000000-0000-0000-0000-000000000010',
   'MAT-2026-010', 'MADZOU', 'Patience Aurélie',
   '2003-02-28', '+242 06 611 0010', 'Ngoyo',
   'A+', 'G1P0 — MAP à 32 SA, hospitalisée pour tocolyse',
   '2026-03-01'),

  -- 11 — Terme dépassé, monitoring intensif
  ('c3000000-0000-0000-0000-000000000011',
   'MAT-2026-011', 'PAMBOU', 'Christelle',
   '1998-05-19', '+242 06 611 0011', 'Siafoumou',
   'O+', 'G2P1 — terme dépassé 41+2 SA, déclenchement en cours',
   '2025-08-20'),

  -- 12 — VIH+ sous traitement ARV, risque modéré-élevé
  ('c3000000-0000-0000-0000-000000000012',
   'MAT-2026-012', 'BAKOUA', 'Madeleine',
   '1990-10-07', '+242 06 611 0012', 'Vindoulou',
   'AB-', 'G3P2 — VIH+ sous ARV (charge virale indétectable), suivi spécialisé PTME',
   '2026-01-08'),

  -- 13 — Grossesse normale à terme
  ('c3000000-0000-0000-0000-000000000013',
   'MAT-2026-013', 'KIMBEMBE', 'Ornella',
   '2002-03-11', '+242 06 611 0013', 'Mbota',
   'B+', 'G1P0 — grossesse physiologique, terme dans 5 jours',
   '2026-02-14'),

  -- 14 — Rupture prématurée des membranes
  ('c3000000-0000-0000-0000-000000000014',
   'MAT-2026-014', 'MILANDOU', 'Véronique',
   '1993-07-16', '+242 06 611 0014', 'Fond-Ntié-Ntié',
   'O+', 'G2P1 — RPM à 36 SA ce matin, admise en urgence',
   '2025-10-05'),

  -- 15 — Adolescente primipare, suivi psychosocial
  ('c3000000-0000-0000-0000-000000000015',
   'MAT-2026-015', 'BITSINDOU', 'Grâce',
   '2009-11-30', '+242 06 611 0015', 'Tié-Tié',
   'A+', 'G1P0 — grossesse adolescente (16 ans), suivi social renforcé',
   '2026-03-10'),

  -- 16 — Grande multipare, anémie sévère
  ('c3000000-0000-0000-0000-000000000016',
   'MAT-2026-016', 'NTSIMBA', 'Marie-Josée',
   '1982-04-02', '+242 06 611 0016', 'Mabombo',
   'O+', 'G6P5 — grande multipare, anémie sévère (Hb 7.2 g/dL), transfusion envisagée',
   '2026-02-18'),

  -- 17 — Hospitalisation pour pré-éclampsie sévère
  ('c3000000-0000-0000-0000-000000000017',
   'MAT-2026-017', 'GOMBO', 'Yvette Laure',
   '1995-09-23', '+242 06 611 0017', 'Mpaka Nord',
   'B+', 'G2P1 — pré-éclampsie sévère diagnostiquée à 36 SA, corticoïdes administrés',
   '2026-01-30'),

  -- 18 — Suivi post-partum par césarienne
  ('c3000000-0000-0000-0000-000000000018',
   'MAT-2026-018', 'ITOUA', 'Raïssa',
   '1991-12-14', '+242 06 611 0018', 'Kouhouta',
   'A-', 'G3P2 — césar J3, cicatrice propre, allaitement maternel initié',
   '2025-07-15'),

  -- 19 — Grossesse physiologique normale
  ('c3000000-0000-0000-0000-000000000019',
   'MAT-2026-019', 'MBOYO', 'Larissa Céleste',
   '2000-08-25', '+242 06 611 0019', 'Ngoyo Centre',
   'O+', 'G1P0 — 28 SA, suivi régulier, aucune complication détectée',
   '2026-03-20'),

  -- 20 — Grossesse triple (triplets), haut risque extrême
  ('c3000000-0000-0000-0000-000000000020',
   'MAT-2026-020', 'MOUKENGUE', 'Henriette Pauline',
   '1988-06-01', '+242 06 611 0020', 'Tié-Tié Plaine',
   'B-', 'G4P3 — grossesse triple (trichoriaux), hospitalisée depuis 28 SA, repos strict',
   '2025-12-01');



--  5. GROSSESSES  (une par patiente — certaines gémellaires)

INSERT INTO grossesses (patiente_id, date_debut_grossesse, date_accouchement_prevu,
                        terme_actuel_sa, type_grossesse, niveau_risque, pathologies_actives, statut) VALUES

  -- 1 NGOMA — gémellaire, haut risque
  ('c3000000-0000-0000-0000-000000000001', '2025-10-01', '2026-06-25', 38, 'gemellaire',  'eleve',
   'Grossesse gémellaire bichoriale — surveillance renforcée, MAP légère', 'en_cours'),

  -- 2 BOUANGA — pré-éclampsie suspectée
  ('c3000000-0000-0000-0000-000000000002', '2025-09-15', '2026-06-22', 37, 'simple',      'eleve',
   'HTA chronique + pré-éclampsie surajoutée suspecte — TA 148/94 ce matin', 'en_cours'),

  -- 3 MFOUTOU — physiologique normale
  ('c3000000-0000-0000-0000-000000000003', '2025-10-20', '2026-07-27', 32, 'simple',      'normal',
   NULL, 'en_cours'),

  -- 4 KIMPOUNI — utérus cicatriciel
  ('c3000000-0000-0000-0000-000000000004', '2025-11-01', '2026-08-08', 30, 'simple',      'modere',
   'Utérus bi-cicatriciel — césarienne programmée à 39 SA', 'en_cours'),

  -- 5 LOUBOTA — diabète gestationnel
  ('c3000000-0000-0000-0000-000000000005', '2025-10-10', '2026-07-17', 34, 'simple',      'eleve',
   'Diabète gestationnel non équilibré — glycémie à jeun 1.38 g/L', 'en_cours'),

  -- 6 MAVOUNGOU — terme proche
  ('c3000000-0000-0000-0000-000000000006', '2025-09-25', '2026-06-17', 38, 'simple',      'normal',
   NULL, 'en_cours'),

  -- 7 NGATSONO — placenta prævia
  ('c3000000-0000-0000-0000-000000000007', '2025-11-05', '2026-08-12', 29, 'simple',      'eleve',
   'Placenta prævia complet — hospitalisation prolongée, CI formelle à toute activité', 'en_cours'),

  -- 8 BIBAYA — gémellaire
  ('c3000000-0000-0000-0000-000000000008', '2025-10-08', '2026-07-01', 36, 'gemellaire',  'modere',
   'Grossesse gémellaire + anémie ferriprive (Hb 9.8) — fer IV en cours', 'en_cours'),

  -- 9 NKODIA — post-partum
  ('c3000000-0000-0000-0000-000000000009', '2025-08-20', '2026-05-27', 41, 'simple',      'normal',
   NULL, 'terminee'),

  -- 10 MADZOU — menace prématuré
  ('c3000000-0000-0000-0000-000000000010', '2025-12-10', '2026-09-16', 32, 'simple',      'eleve',
   'MAP (Menace d Accouchement Prématuré) — tocolyse par nifédipine, corticoïdes J1', 'en_cours'),

  -- 11 PAMBOU — terme dépassé
  ('c3000000-0000-0000-0000-000000000011', '2025-08-15', '2026-05-22', 42, 'simple',      'modere',
   'Terme dépassé 41+2 SA — monitoring NST anormal, déclenchement par syntocinon', 'en_cours'),

  -- 12 BAKOUA — VIH+
  ('c3000000-0000-0000-0000-000000000012', '2025-10-01', '2026-07-08', 35, 'simple',      'modere',
   'VIH+ traitée — charge virale indétectable, prophylaxie ARV nouveau-né prévue', 'en_cours'),

  -- 13 KIMBEMBE — terme proche
  ('c3000000-0000-0000-0000-000000000013', '2025-10-02', '2026-07-09', 38, 'simple',      'normal',
   NULL, 'en_cours'),

  -- 14 MILANDOU — RPM urgence
  ('c3000000-0000-0000-0000-000000000014', '2025-10-15', '2026-07-22', 36, 'simple',      'eleve',
   'RPM (Rupture Prématurée des Membranes) ce matin 06h30 — antibiothérapie débutée', 'en_cours'),

  -- 15 BITSINDOU — adolescente
  ('c3000000-0000-0000-0000-000000000015', '2025-12-01', '2026-09-07', 27, 'simple',      'modere',
   'Grossesse adolescente — malnutrition légère, suivi psychosocial hebdomadaire', 'en_cours'),

  -- 16 NTSIMBA — grande multipare
  ('c3000000-0000-0000-0000-000000000016', '2025-10-10', '2026-07-17', 34, 'simple',      'eleve',
   'Grande multipare (6ème grossesse) + anémie sévère Hb 7.2 — transfusion en attente', 'en_cours'),

  -- 17 GOMBO — pré-éclampsie sévère
  ('c3000000-0000-0000-0000-000000000017', '2025-10-20', '2026-07-27', 36, 'simple',      'eleve',
   'Pré-éclampsie sévère — TA 162/108, protéinurie 3+, oedèmes généralisés, sulfate de magnésium IV', 'en_cours'),

  -- 18 ITOUA — post-partum césar
  ('c3000000-0000-0000-0000-000000000018', '2025-08-01', '2026-05-08', 41, 'simple',      'normal',
   NULL, 'terminee'),

  -- 19 MBOYO — physiologique
  ('c3000000-0000-0000-0000-000000000019', '2025-12-20', '2026-09-26', 28, 'simple',      'normal',
   NULL, 'en_cours'),

  -- 20 MOUKENGUE — triplets haut risque extrême
  ('c3000000-0000-0000-0000-000000000020', '2026-01-01', '2026-09-05', 27, 'triple',      'eleve',
   'Grossesse triple — RCIU sur J3, polyhydramnios, hospitalisée depuis S28 pour surveillance continue', 'en_cours');


--  6. ADMISSIONS ACTIVES (dossiers en cours)

INSERT INTO admissions (patiente_id, grossesse_id, workspace_id, personnel_referent_id,
                        date_admission, statut, motif_admission, est_signale)
SELECT
  p.id,
  g.id,
  w.id,
  (SELECT id FROM personnel_soignant WHERE role = 'sage_femme' LIMIT 1),
  NOW() - INTERVAL '2 hours',
  'travail_actif',
  'Dossier d admission — Patiente de Tie-Tie à 38 SA — gémellaire phase active',
  TRUE  -- signalé = drapeau rouge priorité
FROM patientes p
JOIN grossesses g ON g.patiente_id = p.id
JOIN workspaces w ON w.type = 'bloc_obstetrical'
WHERE p.numero_dossier = 'MAT-2026-001'
LIMIT 1;

INSERT INTO admissions (patiente_id, grossesse_id, workspace_id, personnel_referent_id,
                        date_admission, statut, motif_admission, est_signale)
SELECT
  p.id, g.id, w.id,
  (SELECT id FROM personnel_soignant WHERE role = 'gyneco_obstetricien' LIMIT 1),
  NOW() - INTERVAL '4 hours',
  'travail_actif',
  'Alerte de tension artérielle — Consultation à Mpaka — TA 148/94 mmHg — pré-éclampsie',
  TRUE
FROM patientes p
JOIN grossesses g ON g.patiente_id = p.id
JOIN workspaces w ON w.type = 'bloc_obstetrical'
WHERE p.numero_dossier = 'MAT-2026-002'
LIMIT 1;

INSERT INTO admissions (patiente_id, grossesse_id, workspace_id, personnel_referent_id,
                        date_admission, statut, motif_admission, est_signale)
SELECT
  p.id, g.id, w.id,
  (SELECT id FROM personnel_soignant WHERE role = 'infirmier' LIMIT 1),
  NOW() - INTERVAL '1 day',
  'post_partum_stable',
  'Suivi post-partum immédiat — Nouveau-né à Lumumba — accouchement voie basse normal',
  FALSE
FROM patientes p
JOIN grossesses g ON g.patiente_id = p.id
JOIN workspaces w ON w.type = 'post_partum'
WHERE p.numero_dossier = 'MAT-2026-009'
LIMIT 1;

INSERT INTO admissions (patiente_id, grossesse_id, workspace_id, personnel_referent_id,
                        date_admission, statut, motif_admission, est_signale)
SELECT
  p.id, g.id, w.id,
  (SELECT id FROM personnel_soignant WHERE role = 'sage_femme' LIMIT 1),
  NOW() - INTERVAL '30 minutes',
  'travail_actif',
  'Rupture prématurée des membranes à 36 SA — Fond-Ntié-Ntié — urgence obstétricale',
  TRUE
FROM patientes p
JOIN grossesses g ON g.patiente_id = p.id
JOIN workspaces w ON w.type = 'bloc_obstetrical'
WHERE p.numero_dossier = 'MAT-2026-014'
LIMIT 1;

INSERT INTO admissions (patiente_id, grossesse_id, workspace_id, personnel_referent_id,
                        date_admission, statut, motif_admission, est_signale)
SELECT
  p.id, g.id, w.id,
  (SELECT id FROM personnel_soignant WHERE role = 'gyneco_obstetricien' LIMIT 1),
  NOW() - INTERVAL '6 hours',
  'observation',
  'Pré-éclampsie sévère — Mpaka Nord — TA 162/108, sulfate de magnésium en cours',
  TRUE
FROM patientes p
JOIN grossesses g ON g.patiente_id = p.id
JOIN workspaces w ON w.type = 'bloc_obstetrical'
WHERE p.numero_dossier = 'MAT-2026-017'
LIMIT 1;



--  7. CONSTANTES VITALES — exemples de monitoring

-- Pré-éclampsie GOMBO — 3 relevés alarmants
INSERT INTO constantes_vitales
  (admission_id, personnel_id, date_mesure, tension_sys, tension_dia,
   frequence_cardiaque, temperature, spo2, dilatation_col_cm, notes)
SELECT
  a.id,
  (SELECT id FROM personnel_soignant WHERE role = 'sage_femme' LIMIT 1),
  NOW() - INTERVAL '5 hours',
  162, 108, 95, 37.4, 98, 3,
  'ALERTE : TA critique — sulfate Mg IV débuté. Oligurie surveillée.'
FROM admissions a
JOIN patientes p ON p.id = a.patiente_id
WHERE p.numero_dossier = 'MAT-2026-017'
LIMIT 1;

INSERT INTO constantes_vitales
  (admission_id, personnel_id, date_mesure, tension_sys, tension_dia,
   frequence_cardiaque, temperature, spo2, dilatation_col_cm, notes)
SELECT
  a.id,
  (SELECT id FROM personnel_soignant WHERE role = 'sage_femme' LIMIT 1),
  NOW() - INTERVAL '3 hours',
  155, 102, 92, 37.6, 97, 4,
  'Légère amélioration TA — poursuite sulfate Mg. Dilatation progresse.'
FROM admissions a
JOIN patientes p ON p.id = a.patiente_id
WHERE p.numero_dossier = 'MAT-2026-017'
LIMIT 1;



--  8. VACCINATIONS — avec numéros de lot

INSERT INTO vaccinations (patiente_id, grossesse_id, personnel_id, type_vaccin,
                          date_vaccination, dose, numero_lot, prochain_rappel)
SELECT p.id, g.id,
  (SELECT id FROM personnel_soignant WHERE role = 'infirmier' LIMIT 1),
  'Tétanos-Diphtérie (VAT)', '2026-02-15', '1ère dose', 'LOT-VAT-2026-A12', '2026-03-15'
FROM patientes p JOIN grossesses g ON g.patiente_id = p.id
WHERE p.numero_dossier = 'MAT-2026-003' LIMIT 1;

INSERT INTO vaccinations (patiente_id, grossesse_id, personnel_id, type_vaccin,
                          date_vaccination, dose, numero_lot, prochain_rappel)
SELECT p.id, g.id,
  (SELECT id FROM personnel_soignant WHERE role = 'infirmier' LIMIT 1),
  'Tétanos-Diphtérie (VAT)', '2026-02-18', '1ère dose', 'LOT-VAT-2026-A12', '2026-03-18'
FROM patientes p JOIN grossesses g ON g.patiente_id = p.id
WHERE p.numero_dossier = 'MAT-2026-006' LIMIT 1;

INSERT INTO vaccinations (patiente_id, grossesse_id, personnel_id, type_vaccin,
                          date_vaccination, dose, numero_lot, prochain_rappel)
SELECT p.id, g.id,
  (SELECT id FROM personnel_soignant WHERE role = 'infirmier' LIMIT 1),
  'Tétanos-Diphtérie (VAT)', '2026-02-20', '1ère dose', 'LOT-VAT-2026-A12', '2026-03-20'
FROM patientes p JOIN grossesses g ON g.patiente_id = p.id
WHERE p.numero_dossier = 'MAT-2026-013' LIMIT 1;

-- NOTE : Ces 3 patientes partagent le MÊME numéro de lot LOT-VAT-2026-A12
-- → La fonctionnalité de "Recherche avancée / Corrélation clinique" (§5, module 3)
--   doit pouvoir les retrouver toutes en recherchant ce numéro de lot.



--  9. RENDEZ-VOUS PLANIFIÉS
INSERT INTO rendez_vous (patiente_id, grossesse_id, personnel_id, workspace_id,
                         date_rdv, type_rdv, statut, notes)
SELECT p.id, g.id,
  (SELECT id FROM personnel_soignant WHERE role = 'gyneco_obstetricien' LIMIT 1),
  (SELECT id FROM workspaces WHERE type = 'consultations_prenatales'),
  NOW() + INTERVAL '2 days',
  'echographie', 'planifie',
  'Écho de contrôle — croissance foetale jumeau B à surveiller — Patiente de Tie-Tie'
FROM patientes p JOIN grossesses g ON g.patiente_id = p.id
WHERE p.numero_dossier = 'MAT-2026-001' LIMIT 1;

INSERT INTO rendez_vous (patiente_id, grossesse_id, personnel_id, workspace_id,
                         date_rdv, type_rdv, statut, notes)
SELECT p.id, g.id,
  (SELECT id FROM personnel_soignant WHERE role = 'gyneco_obstetricien' LIMIT 1),
  (SELECT id FROM workspaces WHERE type = 'consultations_prenatales'),
  NOW() + INTERVAL '5 days',
  'bilan_sanguin', 'planifie',
  'NFS + glycémie post-prandiale — Suivi diabète gestationnel Matendé'
FROM patientes p JOIN grossesses g ON g.patiente_id = p.id
WHERE p.numero_dossier = 'MAT-2026-005' LIMIT 1;

INSERT INTO rendez_vous (patiente_id, grossesse_id, personnel_id, workspace_id,
                         date_rdv, type_rdv, statut, notes)
SELECT p.id, g.id,
  (SELECT id FROM personnel_soignant WHERE role = 'sage_femme' LIMIT 1),
  (SELECT id FROM workspaces WHERE type = 'post_partum'),
  NOW() + INTERVAL '4 days',
  'suivi_post_partum', 'planifie',
  'Suivi post-partum J5 — cicatrisation césarienne — allaitement — Kouhouta'
FROM patientes p JOIN grossesses g ON g.patiente_id = p.id
WHERE p.numero_dossier = 'MAT-2026-018' LIMIT 1;
