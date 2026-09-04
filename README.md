# 📦 Reddit Clone — GitOps Deployment Repo

[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Jenkins](https://img.shields.io/badge/CD-Jenkins-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)

This repo holds the **Kubernetes deployment manifests** for the Reddit Clone app. It's the single source of truth that ArgoCD watches — whatever is committed here is what's running on the cluster.

Application source and the CI pipeline that feeds this repo live here:
👉 **[Reddit-Clone-Deploy](https://github.com/holy-rabbit/Reddit-Clone-Deploy)**

---

## 📐 How this repo fits in

```
Reddit-Clone-Deploy (CI)  ──▶  Jenkins job "Reddit-Clone-CD"  ──▶  updates deployment.yaml
                                        │                              in THIS repo
                                        ▼
                                 git commit + push
                                        │
                                        ▼
                               ArgoCD detects the diff
                                        │
                                        ▼
                          Syncs reddit-clone-deployment on the
                              Kubernetes / EKS cluster
```

The CD Jenkins job checks out this repo, uses `sed` to swap in the new image tag it receives from the CI job, commits, and pushes — no manual editing required.

---

## 📦 Contents

| File | Purpose |
|------|---------|
| `deployment.yaml` | Kubernetes Deployment for `reddit-clone-app` — 1 replica, image `holyrabbit/reddit-clone-pipeline:<tag>`, CPU request 500m / limit 1, container port 3000 |
| `service.yaml` | `LoadBalancer` Service exposing the app on port 3000 |
| `Jenkinsfile` | The **Reddit-Clone-CD** pipeline: checks out this repo, updates the image tag, commits, and pushes |
| `git-commit-push.sh` | Manual helper script to stage, commit (with a prompted message), and push local changes to `main` |

---

## ⚙️ CD Pipeline Stages (from `Jenkinsfile`)

1. **Cleanup Workspace**
2. **Checkout from SCM** — pulls `main` branch of this repo
3. **Update the Deployment Tags** — uses `sed` to replace the image tag in `deployment.yaml` with the `IMAGE_TAG` parameter received from the CI job
4. **Push the changed deployment file to GitHub** — commits as `holy-rabbit` and pushes back to `main`

Once pushed, **ArgoCD** (configured separately, watching this repo) detects the manifest change and automatically syncs the cluster to match.

---

## ☸️ Manifests

**`deployment.yaml`**
- Deployment name: `reddit-clone-deployment`
- Replicas: `1`
- Image: `holyrabbit/reddit-clone-pipeline:<IMAGE_TAG>` (tag updated automatically by the CD job)
- Resources: requests `500m` CPU, limits `1` CPU
- Container port: `3000`

**`service.yaml`**
- Service name: `reddit-clone-service`
- Type: `LoadBalancer`
- Port: `3000` → target port `3000`

---

## 🚀 Connecting ArgoCD to this repo

```bash
argocd app create reddit-clone \
  --repo https://github.com/holy-rabbit/Reddit-Clone-Deploy-GitOps.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --sync-policy automated
```

With automated sync enabled, any push to this repo (including the automated ones from the CD Jenkins job) rolls out to the cluster without manual intervention.

---

## 🔗 Related Repository

| Repo | Purpose |
|------|---------|
| [Reddit-Clone-Deploy](https://github.com/holy-rabbit/Reddit-Clone-Deploy) | Application source + CI pipeline (SonarQube, Trivy, Docker build/push) |
| [Reddit-Clone-Deploy-GitOps](https://github.com/holy-rabbit/Reddit-Clone-Deploy-GitOps) | This repo — deployment manifests synced by ArgoCD |

---

## 👤 Author

**holy-rabbit**
