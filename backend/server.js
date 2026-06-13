require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
// Middleware pour vérifier le token JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Format "Bearer TOKEN"

  if (!token) {
    return res.status(401).json({ error: 'Accès non autorisé' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Token invalide ou expiré' });
    req.user = user;
    next();
  });
}
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
app.get('/api/patients/:id', authenticateToken, async (req, res) => {
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
app.get('/api/workspaces/:id/patients', authenticateToken,  async (req, res) => {
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
app.get('/api/search/lot/:numero_lot',authenticateToken, async (req, res) => {
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
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

// Clé secrète pour JWT (à mettre dans .env plus tard)
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';

// Route de login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email et mot de passe requis' });
  }

  try {
    // Vérifier si l'utilisateur existe
    const user = await pool.query('SELECT * FROM personnel_soignant WHERE email = $1', [email]);
    if (user.rows.length === 0) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    const personnel = user.rows[0];

    // Comparer le mot de passe (hash stocké dans la base avec bcrypt)
    const validPassword = await bcrypt.compare(password, personnel.mot_de_passe_hash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Identifiants invalides' });
    }

    // Générer un token JWT
    const token = jwt.sign(
      { 
        id: personnel.id_personnel, 
        email: personnel.email, 
        role: personnel.role 
      },
      JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.json({ 
      token, 
      user: { 
        id: personnel.id_personnel, 
        nom: personnel.nom, 
        prenom: personnel.prenom, 
        email: personnel.email, 
        role: personnel.role 
      } 
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur API démarré sur http://localhost:${PORT}`);
  console.log(`   GET /api/health`);
  console.log(`   GET /api/patients`);
  console.log(`   GET /api/patients/:id`);
  console.log(`   GET /api/workspaces/:id/patients`);
  console.log(`   GET /api/search/lot/:numero_lot`);
});