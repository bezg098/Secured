import os
from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, date
from functools import wraps

app = Flask(__name__, template_folder='templates')
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'dev-secret-change-me')

# Database config — pulled from environment (Secret Manager via Cloud Run)
DB_USER = os.environ.get('DB_USER', 'secured_user')
DB_PASS = os.environ.get('DB_PASS', 'changeme')
DB_NAME = os.environ.get('DB_NAME', 'secured_db')
DB_HOST = os.environ.get('DB_HOST', 'localhost')

app.config['SQLALCHEMY_DATABASE_URI'] = (
    f'postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# ── Models ────────────────────────────────────────────────────────────────────

class User(db.Model):
    __tablename__ = 'users'
    id       = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(256), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    credentials = db.relationship('Credential', backref='owner', lazy=True)

class Credential(db.Model):
    __tablename__ = 'credentials'
    id          = db.Column(db.Integer, primary_key=True)
    name        = db.Column(db.String(120), nullable=False)
    cred_type   = db.Column(db.String(60), nullable=False)   # e.g. API Key, Password, Certificate
    expires_on  = db.Column(db.Date, nullable=False)
    rotated     = db.Column(db.Boolean, default=False)
    user_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at  = db.Column(db.DateTime, default=datetime.utcnow)

# ── Helpers ───────────────────────────────────────────────────────────────────

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        user = User.query.get(session['user_id'])
        if not user or not user.is_admin:
            flash('Admin access required.', 'danger')
            return redirect(url_for('dashboard'))
        return f(*args, **kwargs)
    return decorated

def get_status(cred):
    """Return green / yellow / red based on days until expiry."""
    if cred.rotated:
        return 'rotated'
    days = (cred.expires_on - date.today()).days
    if days < 0:
        return 'red'
    elif days <= 30:
        return 'yellow'
    return 'green'

# ── Routes ────────────────────────────────────────────────────────────────────

@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username'].strip()
        password = request.form['password']
        if User.query.filter_by(username=username).first():
            flash('Username already taken.', 'danger')
            return redirect(url_for('register'))
        hashed = generate_password_hash(password)
        user = User(username=username, password=hashed)
        db.session.add(user)
        db.session.commit()
        flash('Account created! Please log in.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username'].strip()
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password, password):
            session['user_id'] = user.id
            session['username'] = user.username
            session['is_admin'] = user.is_admin
            return redirect(url_for('dashboard'))
        flash('Invalid username or password.', 'danger')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard():
    user = User.query.get(session['user_id'])
    creds = Credential.query.filter_by(user_id=user.id).order_by(Credential.expires_on).all()
    creds_with_status = [(c, get_status(c)) for c in creds]
    return render_template('dashboard.html', creds=creds_with_status, user=user)

@app.route('/add', methods=['GET', 'POST'])
@login_required
def add_credential():
    if request.method == 'POST':
        name       = request.form['name'].strip()
        cred_type  = request.form['cred_type'].strip()
        expires_on = datetime.strptime(request.form['expires_on'], '%Y-%m-%d').date()
        cred = Credential(
            name=name,
            cred_type=cred_type,
            expires_on=expires_on,
            user_id=session['user_id']
        )
        db.session.add(cred)
        db.session.commit()
        flash('Credential added.', 'success')
        return redirect(url_for('dashboard'))
    return render_template('add_credential.html')

@app.route('/rotate/<int:cred_id>', methods=['POST'])
@login_required
def rotate(cred_id):
    cred = Credential.query.get_or_404(cred_id)
    if cred.user_id != session['user_id'] and not session.get('is_admin'):
        flash('Not authorized.', 'danger')
        return redirect(url_for('dashboard'))
    cred.rotated = True
    db.session.commit()
    flash(f'"{cred.name}" marked as rotated.', 'success')
    return redirect(url_for('dashboard'))

@app.route('/admin')
@admin_required
def admin():
    all_creds = Credential.query.order_by(Credential.expires_on).all()
    creds_with_status = [(c, get_status(c)) for c in all_creds]
    users = User.query.all()
    return render_template('admin.html', creds=creds_with_status, users=users)

# ── Init ──────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=8080, debug=False)
