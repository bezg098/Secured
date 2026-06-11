Secured — Deployment Guide
A step-by-step guide for a new team member to set up, run, and deploy the Secured Credential Rotation Tracker.

Prerequisites
Make sure you have the following installed:

Python 3.11+
Docker
Terraform 1.5+
Google Cloud SDK (gcloud)
GitHub account with access to github.com/bezg098/Secured


1. Clone the Repository
bashgit clone https://github.com/bezg098/Secured.git
cd Secured

2. Authenticate with Google Cloud
bashgcloud auth login
gcloud config set project secured-498301
Make sure you are inside the correct project before running any commands.

3. Set Up Infrastructure (terraform/infrastructure/)
This deploys the VPC, Cloud SQL (PostgreSQL), and Secret Manager secrets.
bashcd terraform/infrastructure
terraform init
terraform plan
terraform apply
This creates:

VPC network: cis410-vpc
Cloud SQL instance: secured-db (PostgreSQL 15, private IP 10.100.0.3)
Secret Manager secrets: secured-db-password, secured-flask-secret
VPC connector for Cloud Run to Cloud SQL private connection


Note: Never hardcode secrets. All credentials are stored in Secret Manager and accessed at runtime by the Cloud Run service account.


4. Set Up GitHub Actions Variables
Go to github.com/bezg098/Secured → Settings → Secrets and Variables → Actions → Variables and confirm these are set:
VariableValueGCP_PROJECT_IDsecured-498301SA_EMAILgithub-actions-sa@secured-498301.iam.gserviceaccount.comTF_VAR_PROJECT_IDsecured-498301WIF_PROVIDERprojects/330158972062/locations/global/...
These are used by the CI/CD pipeline for OIDC authentication — no stored credentials needed.

5. Deploy the Application (CI/CD Pipeline)
Every push to main triggers the automated pipeline which:

Triggers on push to main or pull request merge
Builds the Docker container image from the Dockerfile
Runs Snyk SAST scan (Python source code)
Runs Snyk SCA scan (requirements.txt dependencies)
Runs Snyk container scan (Docker image)
Pushes the scanned image to Artifact Registry tagged with commit SHA
Runs terraform apply in terraform/app/ to deploy new Cloud Run revision
Application is live at: https://secured-app-330158972062.us-west1.run.app


Important: Never push directly to main. All changes must go through a pull request reviewed and approved by the Security Reviewer (Asefa) before the Project Lead (Abduba) merges.


6. Git Workflow
bash# Step 1 - Create a feature branch
git checkout -b feature/your-feature-name

# Step 2 - Make changes and commit
git add .
git commit -m "feat: description of change"

# Step 3 - Push branch
git push origin feature/your-feature-name

# Step 4 - Open a Pull Request on GitHub
# Assign Asefa (asefa-belete) as reviewer
# Wait for CI/CD pipeline to pass
# Asefa approves → Abduba merges

7. Running the App Locally (Optional)
bashcd backend
python -m venv venv
source venv/bin/activate  # Mac/Linux
pip install -r requirements.txt
flask run
Visit http://localhost:5000 in your browser.

Note: Local run requires a local PostgreSQL instance or a connection to Cloud SQL via Cloud SQL Auth Proxy.


8. Security Notes

All secrets are stored in GCP Secret Manager — never in code or .env files
terraform.tfvars is gitignored — never commit it
The GitHub Actions pipeline uses OIDC (Workload Identity Federation) — no long-lived credentials
Service accounts follow least-privilege IAM:

github-actions-sa: Artifact Registry Admin, Cloud Run Admin, Service Account Token Creator, Storage Admin
secured-cloudrun-sa: Cloud SQL Client only


Snyk scans run on every push — zero critical vulnerabilities required before demo


9. Team Roles
NameRoleGitHubAbdubaProject Leadbezg098Sayed / AbdubaBackend Engineernawidhashimi786-ui / bezg098SeelaFrontend EngineerSeelalankaraElisDevSecOps Engineersudo-EMAsefaSecurity Reviewerasefa-belete

Live App
URL: https://secured-app-330158972062.us-west1.run.app
GitHub Repo: https://github.com/bezg098/Secured
