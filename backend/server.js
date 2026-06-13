require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

// Clé secrète JWT
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';

// Middleware d'authentification
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Accès non autorisé' });
  }
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Token invalide ou expiré' });
    req.user = user;
    next();
  });
}

// Connexion PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

pool.connect((err) => {
  if (err) return console.error('❌ Erreur de connexion à PostgreSQL :', err.stack);
  console.log('✅ Connecté à PostgreSQL');
});

// Configuration multer pour l'upload
const uploadDir = './uploads';
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowed = ['image/jpeg', 'image/png', 'application/pdf'];
  allowed.includes(file.mimetype) ? cb(null, true) : cb(new Error('Type de fichier non autorisé'), false);
};

const upload = multer({ storage, fileFilter });

// ========== ROUTES ==========

// Santé
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'API MaterniteCare avec PostgreSQL' });
});

// Liste publique des patientes
app.get('/api/patients', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM vue_patiente_public ORDER BY nom');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Détail patiente (protégé)
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

// Patientes d'un workspace (protégé)
app.get('/api/workspaces/:id/patients', authenticateToken, async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(`
      SELECT 
        p.id_patiente, p.numero_dossier, p.nom, p.prenom, p.date_naissance, p.quartier,
        g.niveau_risque, g.terme_actuel_sa,
        a.statut_admission, a.est_critique
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

// Recherche par lot de vaccin (protégé)
app.get('/api/search/lot/:numero_lot', authenticateToken, async (req, res) => {
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

// Route de login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ error: 'Email et mot de passe requis' });
  try {
    const user = await pool.query('SELECT * FROM personnel_soignant WHERE email = $1', [email]);
    if (user.rows.length === 0) return res.status(401).json({ error: 'Identifiants invalides' });
    const personnel = user.rows[0];
    const validPassword = await bcrypt.compare(password, personnel.mot_de_passe_hash);
    if (!validPassword) return res.status(401).json({ error: 'Identifiants invalides' });
    const token = jwt.sign(
      { id: personnel.id_personnel, email: personnel.email, role: personnel.role },
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

// Upload par patiente (avec code dossier)
app.post('/api/upload/:codeDossier', upload.single('document'), async (req, res) => {
  const { codeDossier } = req.params;
  if (!req.file) return res.status(400).json({ error: 'Aucun fichier envoyé' });
  try {
    const patient = await pool.query('SELECT id_patiente FROM patiente WHERE numero_dossier = $1', [codeDossier]);
    if (patient.rows.length === 0) return res.status(404).json({ error: 'Code dossier invalide' });
    await pool.query(
      `INSERT INTO document_medical (patiente_id, titre, chemin_fichier, type_mime, taille_octets, upload_par_patiente, est_valide)
       VALUES ($1, $2, $3, $4, $5, true, true)`,
      [patient.rows[0].id_patiente, req.file.originalname, req.file.path, req.file.mimetype, req.file.size]
    );
    res.json({ message: 'Document uploadé avec succès' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Upload par soignant (protégé)
app.post('/api/documents', authenticateToken, upload.single('document'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Aucun fichier envoyé' });
  const { patienteId } = req.body;
  if (!patienteId) return res.status(400).json({ error: 'ID patiente requis' });
  try {
    const patient = await pool.query('SELECT id_patiente FROM patiente WHERE id_patiente = $1', [patienteId]);
    if (patient.rows.length === 0) return res.status(404).json({ error: 'Patiente non trouvée' });
    await pool.query(
      `INSERT INTO document_medical (patiente_id, personnel_id, titre, chemin_fichier, type_mime, taille_octets, upload_par_patiente, est_valide)
       VALUES ($1, $2, $3, $4, $5, $6, false, true)`,
      [patienteId, req.user.id, req.file.originalname, req.file.path, req.file.mimetype, req.file.size]
    );
    res.json({ message: 'Document ajouté au dossier patient' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Démarrer le serveur
const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
  console.log(`🚀 Serveur API démarré sur http://localhost:${PORT}`);
  console.log(`   GET /api/health`);
  console.log(`   GET /api/patients`);
  console.log(`   GET /api/patients/:id`);
  console.log(`   GET /api/workspaces/:id/patients`);
  console.log(`   GET /api/search/lot/:numero_lot`);
  console.log(`   POST /api/auth/login`);
  console.log(`   POST /api/upload/:codeDossier`);
  console.log(`   POST /api/documents (protégé JWT)`);
});