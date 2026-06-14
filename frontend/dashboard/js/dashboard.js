const API_URL = 'http://localhost:3003';
let token = null;
let currentUser = null;

const loginBtn = document.getElementById('btnLogin');
const logoutBtn = document.getElementById('btnLogout');
const loginZone = document.getElementById('loginZone');
const dashboardZone = document.getElementById('dashboardZone');
const loginError = document.getElementById('loginError');

loginBtn.addEventListener('click', async () => {
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value.trim();
    if (!email || !password) {
        loginError.innerText = 'Veuillez remplir tous les champs';
        return;
    }
    loginError.innerText = '';
    loginBtn.disabled = true;
    loginBtn.innerText = 'Connexion...';
    try {
        const res = await fetch(`${API_URL}/api/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.error || 'Identifiants invalides');
        token = data.token;
        currentUser = data.user;
        localStorage.setItem('token', token);
        document.getElementById('userName').innerText = `${currentUser.prenom} ${currentUser.nom}`;
        document.getElementById('userRole').innerText = currentUser.role;
        document.getElementById('userWorkspace').innerText = 'Maternité centrale';
        loginZone.style.display = 'none';
        dashboardZone.style.display = 'block';
        logoutBtn.style.display = 'inline-block';
        await loadPatients();
    } catch (err) {
        loginError.innerText = err.message;
    } finally {
        loginBtn.disabled = false;
        loginBtn.innerText = 'Se connecter';
    }
});

logoutBtn.addEventListener('click', () => {
    token = null;
    currentUser = null;
    localStorage.removeItem('token');
    loginZone.style.display = 'block';
    dashboardZone.style.display = 'none';
    logoutBtn.style.display = 'none';
});

async function loadPatients() {
    try {
        const res = await fetch(`${API_URL}/api/patients`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const patients = await res.json();
        displayPatients(patients);
    } catch (err) {
        console.error(err);
    }
}

function displayPatients(patients) {
    const container = document.getElementById('patientList');
    container.innerHTML = patients.map(p => `
        <div class="card card--risque-${p.niveau_risque || 'normal'}">
            <strong>${p.prenom} ${p.nom}</strong>
            <span class="badge badge--${p.niveau_risque === 'eleve' ? 'danger' : (p.niveau_risque === 'modere' ? 'warning' : 'neutral')}">${p.niveau_risque || 'normal'}</span>
            <div class="meta">📁 ${p.numero_dossier} · ${p.quartier || 'Quartier inconnu'}</div>
            <div>🤰 ${p.terme_actuel_sa || '?'} SA</div>
        </div>
    `).join('');
}