# Personal Finance App

Aplikasi pencatatan keuangan pribadi dengan arsitektur monorepo, terdiri dari REST API Backend (Docker, MinIO Object Storage, Google Apps Script, AI Vision) dan Mobile Application Client.

---

## 📁 Struktur Monorepo

```text
finance-app/
├── backend/                  # REST API Gateway & Microservices
│   ├── src/                  # Node.js Express REST API source code
│   ├── docker-compose.yml    # Docker Compose (API, MinIO, Cloudflared)
│   ├── Dockerfile            # Multi-stage production container build
│   ├── .env.example          # Template environment variables
│   ├── code.js               # Google Apps Script Web App source code
│   └── README.md             # Dokumentasi lengkap backend API & deployment
│
├── mobile/                   # Mobile Application (Flutter / React Native)
│
├── .gitignore                # Root gitignore rules
└── README.md                 # Root monorepo documentation
```

---

## 🚀 Quick Start Backend

Masuk ke direktori `backend/`:

```bash
cd backend

# Salin template konfigurasi environment
cp .env.example .env

# Jalankan backend dan MinIO via Docker Compose
docker compose up -d

# Atau jalankan bersama Cloudflare Tunnel (jika token telah diisi di .env)
docker compose --profile tunnel up -d
```

Dokumentasi lengkap mengenai endpoint API, testing, konfigurasi MinIO, dan deployment dapat dilihat di [backend/README.md](backend/README.md).
