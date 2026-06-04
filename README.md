# Secured — Credential Rotation Tracker

CIS 410 Capstone Project | Team: Bez, Gin, Lia, Eli, Asila

A secure internal web application for tracking and rotating credentials (API keys, passwords, certificates) across an organization.

---

## Team Roles

| Member | Role |
|--------|------|
| Bez    | Project Lead |
| Gin    | Backend Engineer |
| Lia    | Frontend Engineer |
| Eli    | DevSecOps Engineer |
| Asila  | Security Reviewer |

---

## Tech Stack

- **Backend:** Python Flask + SQLAlchemy
- **Frontend:** HTML / CSS / Jinja2 templates
- **Database:** Cloud SQL PostgreSQL
- **Hosting:** Cloud Run (GCP)
- **IaC:** Terraform (split into `infrastructure/` and `app/`)
- **CI/CD:** GitHub Actions
- **Security:** Snyk (SAST + SCA + container scanning)

---

## Project Structure

```
secured-capstone/
├── backend/
│   ├── app.py                  # Flask application
│   ├── requirements.txt
│   ├── Dockerfile
│   └── templates/              # Jinja2 HTML templates
├── terraform/
│   ├── infrastructure/         # VPC, Cloud SQL, Secret Manager, IAM (run once)
│   └── app/                    # Cloud Run, Artifact Registry (run by CI/CD)
├── .github/
│   └── workflows/
│       └── ci-cd.yml           # GitHub Actions pipeline
├── .gitignore
└── README.md
```

---

## GitHub Variables Required

Set these in **Settings → Secrets and Variables → Actions**:

| Name | Type | Description |
|------|------|-------------|
| `GCP_PROJECT_ID` | Variable | Your GCP project ID |
| `WIF_PROVIDER` | Variable | Workload Identity Federation provider |
| `SA_EMAIL` | Variable | GCP service account email |
| `SNYK_TOKEN` | **Secret** | Snyk API token |

---

## Local Development

```bash
cd backend
pip install -r requirements.txt
export FLASK_SECRET_KEY=dev-secret
export DB_USER=postgres
export DB_PASS=yourpassword
export DB_NAME=secured_db
export DB_HOST=localhost
python app.py
```

---

## Deployment

Infrastructure (run once by DevSecOps):
```bash
cd terraform/infrastructure
terraform init
terraform apply -var="project_id=YOUR_PROJECT" -var="db_password=SECRET" -var="flask_secret_key=SECRET"
```

App (handled automatically by GitHub Actions on push to main).

---

## Security Commitments

- Least-privilege IAM — Cloud Run service account has only `cloudsql.client` and `secretmanager.secretAccessor`
- No hardcoded secrets — all credentials stored in Secret Manager
- SAST integrated — Snyk Code runs on every push
- Container scanning — Snyk scans the built image before push
- Branch protection — no direct pushes to main
- Peer PR review — Security Reviewer (Asila) reviews every PR
- `terraform.tfvars` is gitignored — no secrets committed
