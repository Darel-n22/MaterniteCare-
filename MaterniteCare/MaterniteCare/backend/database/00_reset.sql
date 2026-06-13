--  MaternitéCare — Reset complet (à utiliser avec précaution !)
 Usage : psql -U postgres -d maternitecare -f 00_reset.sql

DROP TABLE IF EXISTS vaccinations         CASCADE;
DROP TABLE IF EXISTS nouveau_nes           CASCADE;
DROP TABLE IF EXISTS accouchements        CASCADE;
DROP TABLE IF EXISTS examens_documents    CASCADE;
DROP TABLE IF EXISTS rendez_vous          CASCADE;
DROP TABLE IF EXISTS constantes_vitales   CASCADE;
DROP TABLE IF EXISTS admissions           CASCADE;
DROP TABLE IF EXISTS lits                 CASCADE;
DROP TABLE IF EXISTS grossesses           CASCADE;
DROP TABLE IF EXISTS patientes            CASCADE;
DROP TABLE IF EXISTS tokens_session       CASCADE;
DROP TABLE IF EXISTS personnel_soignant   CASCADE;
DROP TABLE IF EXISTS workspaces           CASCADE;

DROP TYPE IF EXISTS type_workspace        CASCADE;
DROP TYPE IF EXISTS role_personnel        CASCADE;
DROP TYPE IF EXISTS groupe_sanguin_type   CASCADE;
DROP TYPE IF EXISTS type_grossesse        CASCADE;
DROP TYPE IF EXISTS niveau_risque_type    CASCADE;
DROP TYPE IF EXISTS statut_grossesse      CASCADE;
DROP TYPE IF EXISTS statut_admission      CASCADE;
DROP TYPE IF EXISTS type_lit              CASCADE;
DROP TYPE IF EXISTS type_rdv              CASCADE;
DROP TYPE IF EXISTS statut_rdv            CASCADE;
DROP TYPE IF EXISTS type_document         CASCADE;
DROP TYPE IF EXISTS type_accouchement     CASCADE;
DROP TYPE IF EXISTS sexe_type             CASCADE;
DROP TYPE IF EXISTS etat_sante_nne        CASCADE;

