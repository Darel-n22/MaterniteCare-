require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

// Connexion à PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Vérification de la connexion
pool.connect((err, client, release) => {
  if (err) return console.error('❌ Erreur de connexion à PostgreSQL :', err.stack);
  console.log('✅ Connecté à PostgreSQL');
  release();
});

// ========== ROUTES ==========

// Santé
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'API MaterniteCare avec PostgreSQL' });
});

// Liste publique des patientes (vue publique)
app.get('/api/patients', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vue_patiente_public ORDER BY nom');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Détail complet d'une patiente (soignant)
app.get('/api/patients/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const patient = await pool.query('SELECT * FROM vue_soignant_restreint WHERE id_patiente = $1', [id]);
    if (patient.rows.length === 0) return res.status(404).json({ error: 'Patiente non trouvée' });
    const grossesses = await pool.query('SELECT * FROM grossesse WHERE patiente_id = $1', [id]);
    const admissions = await pool.query('SELECT * FROM admission WHERE patiente_id = $1 ORDER BY date_admission DESC', [id]);
    res.json({
      patiente: patient.rows[0],
      grossesses: grossesses.rows,
      admissions: admissions.rows
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Patientes d'un workspace (dashboard soignant)
app.get('/api/workspaces/:id/patients', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(`
      SELECT 
        p.id_patiente,
        p.numero_dossier,
        p.nom,
        p.prenom,
        p.date_naissance,
        p.quartier,
        g.niveau_risque,
        g.terme_actuel_sa,
        a.statut_admission,
        a.est_critique
      FROM patiente p
      LEFT JOIN grossesse g ON g.patiente_id = p.id_patiente AND g.statut = 'en_cours'
      LEFT JOIN admission a ON a.patiente_id = p.id_patiente AND a.date_sortie IS NULL
      WHERE a.workspace_id = $1 OR EXISTS (SELECT 1 FROM admission WHERE patiente_id = p.id_patiente AND workspace_id = $1)
      ORDER BY a.est_critique DESC, g.niveau_risque DESC
    `, [id]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Recherche par lot de vaccin (corrélation clinique)
app.get('/api/search/lot/:numero_lot', async (req, res) => {
  const { numero_lot } = req.params;
  try {
    const result = await pool.query(`
      SELECT DISTINCT p.id_patiente, p.nom, p.prenom, p.numero_dossier, p.quartier,
                      v.type_vaccin, v.date_vaccination, v.numero_lot
      FROM vaccination v
      JOIN patiente p ON p.id_patiente = v.patiente_id
      WHERE v.numero_lot = $1
      ORDER BY p.nom
    `, [numero_lot]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Démarrer le serveur
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur API démarré sur http://localhost:${PORT}`);
  console.log(`   GET /api/health`);
  console.log(`   GET /api/patients`);
  console.log(`   GET /api/patients/:id`);
  console.log(`   GET /api/workspaces/:id/patients`);
  console.log(`   GET /api/search/lot/:numero_lot`);
});