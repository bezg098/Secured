# Project Milestones & Task Assignments
## Secured — CIS 410 Capstone | Group 2

**GitHub Repo:** https://github.com/bezg098/Secured
**Live App:** https://secured-app-330158972062.us-west1.run.app
**GCP Project:** secured-498301

---

## Team Roles & Assignments

| Member | Role | GitHub | Responsibilities |
|--------|------|--------|-----------------|
| Abduba | Project Lead | bezg098 | Architecture diagram, GitHub repo setup, branch protection, coordinates team |
| Sayed | Backend Engineer | nawidhashimi786-ui | Flask app, Dockerfile, Cloud Run Terraform config |
| Seela | Frontend Engineer | Seelalankara | HTML/Jinja2 templates, UI, static assets |
| Elis | DevSecOps Engineer | sudo-EM | GitHub Actions pipeline, Snyk scanning, IAM, Secret Manager |
| Asefa | Security Reviewer | asefa-belete | IAM audit, PR reviews, README, final security scan |

---

## Week 9 Milestones ✅

| Deliverable | Owner | Status | Completed |
|-------------|-------|--------|-----------|
| Sections 1-3 One-Pager completed | All members | ✅ Done | Week 9 |
| Sections 4-9 One-Pager completed | All members | ✅ Done | Week 9 |
| GitHub repo created (bezg098/Secured) | Abduba | ✅ Done | Week 9 |
| Branch protection enabled on main | Abduba | ✅ Done | Week 9 |
| All teammates added as collaborators | Abduba | ✅ Done | Week 9 |
| GCP project created (secured-498301) | Elis | ✅ Done | Week 9 |
| GCP IAM roles granted to all team members | Elis | ✅ Done | Week 9 |

---

## Week 10 Milestones ✅

| Deliverable | Owner | Status | Completed |
|-------------|-------|--------|-----------|
| Architecture diagram committed to repo | Abduba | ✅ Done | Week 10 |
| Initial folder structure in repo | Abduba | ✅ Done | Week 10 |
| OIDC Workload Identity Federation configured | Elis | ✅ Done | Week 10 |
| GitHub Variables set (WIF_PROVIDER, SA_EMAIL, GCP_PROJECT_ID) | Abduba + Elis | ✅ Done | Week 10 |
| GitHub Secret set (SNYK_TOKEN) | Abduba | ✅ Done | Week 10 |
| terraform/infrastructure/ committed | Elis | ✅ Done | Week 10 |
| terraform/app/ committed | Elis | ✅ Done | Week 10 |
| README.md updated with all required info | Asefa | ✅ Done | Week 10 |
| Team roles confirmed and documented | Abduba | ✅ Done | Week 10 |

---

## Week 11 Milestones ✅

| Deliverable | Owner | Status | Completed |
|-------------|-------|--------|-----------|
| Flask app code committed — frontend and backend functional | Sayed + Seela | ✅ Done | Week 11 |
| Dockerfile written and image building successfully | Sayed + Elis | ✅ Done | Week 11 |
| Terraform infrastructure applied (VPC, Cloud SQL, Secret Manager, IAM) | Elis | ✅ Done | Week 11 |
| Terraform app applied (Cloud Run, Artifact Registry) | Elis | ✅ Done | Week 11 |
| GitHub Actions CI/CD pipeline passing — all Snyk scans green | Elis | ✅ Done | Week 11 |
| Application deployed to GCP via HTTPS | All members | ✅ Done | Week 11 |
| README + architecture diagram + deployment guide complete | Asefa | ✅ Done | Week 11 |
| Final Snyk security scan — 0 critical vulnerabilities | Asefa | ✅ Done | Week 11 |
| Live demo rehearsed — 15-20 min presentation ready | All members | ⏳ In progress | Week 11 |

---

## Architecture Overview

```
User (Browser)
    |  HTTPS
    v
Cloud Run (Flask app — Secured)
    |  private IP (VPC Connector)
    v
Cloud SQL PostgreSQL (cis410-vpc)

Cloud Run also reads from:
    Secret Manager --> DB_PASSWORD, FLASK_SECRET_KEY

GitHub Actions CI/CD:
    Push to main --> Build image --> Snyk scans --> 
    Push to Artifact Registry --> Deploy to Cloud Run
```

---

## Security Commitments — All Implemented ✅

- ✅ Least-privilege IAM — Cloud Run SA has only cloudsql.client + secretAccessor
- ✅ No hardcoded secrets — DB_PASS and FLASK_SECRET_KEY in Secret Manager
- ✅ SAST — Snyk Code runs on every push to main
- ✅ Container scanning — Snyk scans Docker image before push
- ✅ Branch protection — no direct pushes to main
- ✅ PR review — Asefa approves every PR before merge
- ✅ 0 critical vulnerabilities in final Snyk scan
- ✅ terraform.tfvars gitignored — no secrets in GitHub

---

## GCP Resources

| Resource | Name | Status |
|----------|------|--------|
| Project | secured-498301 | ✅ Active |
| Cloud Run | secured-app | ✅ Running |
| Cloud SQL | secured-db (PostgreSQL 15) | ✅ Running |
| VPC Network | cis410-vpc | ✅ Active |
| VPC Connector | secured-connector | ✅ Active |
| Artifact Registry | secured | ✅ Active |
| Secret Manager | secured-db-password, secured-flask-secret | ✅ Active |
| GCS Bucket | secured-terraform-state-498301 | ✅ Active |

---

*Last updated: June 7, 2026 | CIS 410 Cybersecurity Automation | Highline College*
