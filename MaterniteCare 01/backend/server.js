require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Test connexion DB
pool.connect((err, client, release) => {
  if (err) return console.error('❌ Erreur PostgreSQL :', err.stack);
  console.log('✅ Connecté à PostgreSQL');
  release();
});

// Route de santé
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'API MaterniteCare opérationnelle' });
});

// Récupérer TOUTES les patientes (avec leurs grossesses en cours et admission active)
app.get('/api/patients', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        p.id, p.numero_dossier, p.nom, p.prenom, p.date_naissance, p.telephone, p.quartier,
        g.niveau_risque, g.terme_actuel_sa, g.pathologies_actives,
        a.statut as statut_admission, a.est_signale, a.workspace_id
      FROM patientes p
      LEFT JOIN grossesses g ON g.patiente_id = p.id AND g.statut = 'en_cours'
      LEFT JOIN admissions a ON a.patiente_id = p.id AND a.date_sortie IS NULL
      ORDER BY p.nom
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer les patientes d'un workspace (unité médicale) – route demandée
app.get('/api/workspaces/:id/patients', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(`
      SELECT 
        p.id, p.numero_dossier, p.nom, p.prenom, p.telephone, p.quartier,
        g.niveau_risque, g.terme_actuel_sa,
        a.statut as statut_admission, a.est_signale
      FROM admissions a
      JOIN patientes p ON p.id = a.patiente_id
      LEFT JOIN grossesses g ON g.patiente_id = p.id AND g.statut = 'en_cours'
      WHERE a.workspace_id = $1 AND a.date_sortie IS NULL
      ORDER BY a.est_signale DESC, g.niveau_risque DESC
    `, [id]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Détail complet d'une patiente (dossier médical)
app.get('/api/patients/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const patient = await pool.query('SELECT * FROM patientes WHERE id = $1', [id]);
    if (patient.rows.length === 0) return res.status(404).json({ error: 'Patiente non trouvée' });
    const grossesses = await pool.query('SELECT * FROM grossesses WHERE patiente_id = $1', [id]);
    const admissions = await pool.query('SELECT * FROM admissions WHERE patiente_id = $1 ORDER BY date_admission DESC', [id]);
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

// Route pour la recherche par lot de vaccin (corrélation clinique)
app.get('/api/search/lot/:numero_lot', async (req, res) => {
  const { numero_lot } = req.params;
  try {
    const result = await pool.query(`
      SELECT DISTINCT p.id, p.nom, p.prenom, p.numero_dossier, p.telephone, p.quartier,
                      v.type_vaccin, v.date_vaccination, v.numero_lot
      FROM vaccinations v
      JOIN patientes p ON p.id = v.patiente_id
      WHERE v.numero_lot = $1
    `, [numero_lot]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 API MaterniteCare démarrée sur http://localhost:${PORT}`);
  console.log(`   GET /api/health`);
  console.log(`   GET /api/patients`);
  console.log(`   GET /api/workspaces/:id/patients`);
  console.log(`   GET /api/patients/:id`);
  console.log(`   GET /api/search/lot/:numero_lot`);
});