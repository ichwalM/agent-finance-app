# Personal Finance REST API Backend

Production-ready REST API backend untuk aplikasi pencatatan keuangan pribadi, berfungsi sebagai API Gateway antara Mobile App, Google Sheets (via Google Apps Script Web App), dan Google Gemini Vision API (Receipt Scanner).

Dirancang untuk di-deploy pada **Home Server** menggunakan **Docker** dan **Docker Compose**.

---

## 1. Arsitektur Service

```text
Mobile Application
       │
       ▼
REST API Backend (Port 3000)
       │
       ├──► Google Apps Script Web App ──► Google Sheets (Database Transaksi)
       │
       ├──► AI Receipt Vision Engine ────► 9Router (web-dev) ATAU Google Gemini Direct
       │
       └──► MinIO Object Storage (S3) ──► Host Mount: /mnt/HDD/minio/data
                                          (Web Console: :9001 | API: :9000)
```

- **API Gateway Pattern:** Mobile app hanya berkomunikasi dengan backend REST API ini.
- **Dual AI Provider:** Mendukung **9Router** (`AI_PROVIDER=9router`) dan **Google Gemini Direct** (`AI_PROVIDER=gemini`).
- **Object Storage MinIO:** Setiap foto struk yang diunggah otomatis diarsipkan ke MinIO Object Storage (tersinkronisasi langsung ke drive `/mnt/HDD/minio/data` pada host).
- **Keamanan Kredensial:** API Key dan credentials disimpan aman di backend (`.env`) dan tidak pernah diekspos ke client.
- **Decoupled Receipt Scanning:** Hasil scan struk mengembalikan JSON terstruktur serta `image_url` dan `image_key`. Data **tidak langsung disimpan** ke Google Sheets sampai user mengonfirmasi/menyimpan di mobile app (`POST /api/transactions`).
- **Streaming Gateway:** Gambar struk dapat diakses kembali secara aman lewat API backend melalui `GET /api/receipts/:folder/:fileName` tanpa perlu membuka akses bucket secara publik jika tidak diinginkan.

---

## 2. Requirements

- [Docker Engine](https://docs.docker.com/engine/install/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/) (v2.0+)
- Google Gemini API Key ([Google AI Studio](https://aistudio.google.com/))
- Google Apps Script Web App URL (terhubung ke Google Sheets)

---

## 3. Instalasi & Deployment

### Langkah 1: Clone / Copy Project

Pastikan project berada di direktori home server Anda:

```bash
cd /path/to/finance-app
```

### Langkah 2: Konfigurasi Environment Variables

Salin template `.env.example` ke `.env`:

```bash
cp .env.example .env
```

Buka dan sesuaikan nilai di `.env`:

```env
NODE_ENV=production
PORT=3000

# AI Provider: '9router' atau 'gemini'
AI_PROVIDER=9router

# 9Router Configuration
ROUTER9_BASE_URL=https://agent.walldev.my.id/v1
ROUTER9_API_KEY=sk-...
ROUTER9_MODEL=web-dev
ROUTER9_TIMEOUT_MS=30000

# Google Gemini Official API (Opsional jika AI_PROVIDER=gemini)
GEMINI_API_KEY=AIzaSy...
GEMINI_MODEL=gemini-1.5-flash
GEMINI_TIMEOUT_MS=30000

# Google Apps Script Web App URL
GAS_URL=https://script.google.com/macros/s/AKfycbzwfqXJUWiiX9geiQk4yTICcTHbxruPaO-4o5evC2f0LUV__TzZPv1wVaWULYlM50vB/exec
GAS_TIMEOUT_MS=10000

# CORS Allowed Origins
CORS_ORIGIN=http://localhost:3000

# Rate Limiting khusus /api/scan-receipt
SCAN_RATE_LIMIT_WINDOW_SECONDS=60
SCAN_RATE_LIMIT_MAX=10
```

### Langkah 3: Build & Jalankan Container

Build image dan jalankan container di background:

```bash
docker compose build
docker compose up -d
```

### Langkah 4: Verifikasi Status Container

Cek apakah container berjalan dan berstatus healthy:

```bash
docker compose ps
```

Periksa log container:

```bash
docker compose logs -f
```

---

## 4. Manajemen Layanan

- **Melihat status:**
  ```bash
  docker compose ps
  ```

- **Melihat logs realtime:**
  ```bash
  docker compose logs -f
  ```

- **Restart layanan:**
  ```bash
  docker compose restart
  ```

- **Menghentikan layanan:**
  ```bash
  docker compose down
  ```

- **Update setelah perubahan source code:**
  ```bash
  docker compose up -d --build
  ```

---

## 5. Dokumentasi API & Contoh Usage (cURL)

Base URL: `http://localhost:3000`

### 1. Health Check
Memeriksa status container dan kesiapan server (digunakan untuk Docker healthcheck).

```bash
curl http://localhost:3000/api/health
```

**Response (200 OK):**
```json
{
  "success": true,
  "status": "ok",
  "timestamp": "2026-09-25T09:20:00.000Z"
}
```

---

### 2. Mengambil Semua Transaksi (GET)
Meneruskan request ke Google Apps Script untuk mengambil data riwayat transaksi.

```bash
curl http://localhost:3000/api/transactions
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "row": 2,
      "tanggal": "2026-09-25",
      "kategori": "Needs",
      "sub_kategori": "Makan & Minum",
      "deskripsi": "Alfamart",
      "nominal": 25000
    }
  ]
}
```

---

### 3. Membuat Transaksi Baru (POST)
Menambahkan transaksi baru ke Google Sheets. Backend otomatis menambahkan `"action": "create"`.

```bash
curl -X POST http://localhost:3000/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "tanggal": "2026-09-25",
    "kategori": "Needs",
    "sub_kategori": "Makan & Minum",
    "deskripsi": "Alfamart",
    "nominal": 25000
  }'
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "status": "success",
    "message": "Transaction created successfully"
  }
}
```

---

### 4. Mengubah Transaksi (PUT)
Memperbarui transaksi berdasarkan nomor baris (`row`). Backend otomatis menyisipkan `"action": "update"` dan `"row": 4`.

```bash
curl -X PUT http://localhost:3000/api/transactions/4 \
  -H "Content-Type: application/json" \
  -d '{
    "tanggal": "2026-09-25",
    "kategori": "Needs",
    "sub_kategori": "Makan & Minum",
    "deskripsi": "Indomaret",
    "nominal": 30000
  }'
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "status": "success",
    "message": "Row updated successfully"
  }
}
```

---

### 5. Menghapus Transaksi (DELETE)
Menghapus baris transaksi berdasarkan nomor baris (`row`). Backend otomatis menyisipkan `"action": "delete"` dan `"row": 4`.

```bash
curl -X DELETE http://localhost:3000/api/transactions/4
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "status": "success",
    "message": "Row deleted successfully"
  }
}
```

---

### 6. Scan Struk Pembayaran (POST Receipt Scanner)
Mengunggah file struk belanja (`JPEG`, `PNG`, atau `WebP` hingga 5 MB). File struk otomatis disimpan ke Object Storage (MinIO) dan dianalisis oleh AI Vision (9Router / Gemini).

> **Catatan:** Endpoint ini **tidak** langsung menyimpan ke Google Sheets! Mobile app menampilkan hasil ini ke user untuk diverifikasi sebelum disimpan.

```bash
curl -X POST http://localhost:3000/api/scan-receipt \
  -F "receipt=@receipt.jpg"
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "tanggal": "2026-09-25",
    "nominal": 45000,
    "kategori": "Needs",
    "sub_kategori": "Makan & Minum",
    "deskripsi": "Alfamart",
    "image_url": "http://localhost:9000/receipts/20260925/e78ec0a2-e082-43a2-b65f-37e9ecd72fbe.jpg",
    "image_key": "20260925/e78ec0a2-e082-43a2-b65f-37e9ecd72fbe.jpg"
  }
}
```

---

### 7. Mengambil File Struk dari Storage (GET)
Mengambil file struk yang telah diarsipkan melalui streaming gateway backend REST API.

```bash
curl http://localhost:3000/api/receipts/20260925/e78ec0a2-e082-43a2-b65f-37e9ecd72fbe.jpg --output struk.jpg
```

---

## 6. Object Storage MinIO & Volume Mounts

Setiap foto yang di-upload ke sistem diarsipkan secara otomatis ke MinIO Object Storage yang disinkronisasikan ke drive fisik server:

| Path Host | Path Container | Keterangan |
| :--- | :--- | :--- |
| `/mnt/HDD/minio/data` | `/data` | Tempat penyimpanan file foto struk (`receipts/<YYYYMMDD>/<UUID>.<ext>`) |
| `/mnt/HDD/minio/config` | `/root/.minio` | Konfigurasi sistem dan metadata MinIO |

### Akses MinIO:
- **MinIO S3 API:** `http://localhost:9000` (atau IP server Anda: `http://<ip-server>:9000`)
- **MinIO Web Console GUI:** `http://localhost:9001` (login default: `admin` / `password123`)

---

## 7. Validasi Kategori & Sub-Kategori

Sistem memberlakukan validasi ketat terhadap pasangan kategori dan sub-kategori:

| Kategori | Sub-Kategori yang Diizinkan |
| :--- | :--- |
| **Needs** | `Sewa Kost`, `Makan & Minum`, `Transport & Bensin`, `Internet & Kuota` |
| **Wants** | `Kopi & Nongkrong`, `Jajan & Hiburan` |
| **Simpanan** | `Dana Darurat` |
| **Investasi** | `RDPU / Saham / Emas` |

Jika client mengirimkan sub-kategori yang tidak sesuai dengan kategorinya, sistem akan menolak dengan error `400 Bad Request` (`VALIDATION_ERROR`).

---

## 8. Format Error Standar

Semua error yang terjadi dikembalikan dalam format standar tanpa mengekspos internal stack trace, file path, maupun API key:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "sub_kategori",
        "message": "sub_kategori 'Kopi & Nongkrong' tidak valid untuk kategori 'Needs'"
      }
    ]
  }
}
```

---

## 9. Menjalankan Unit & Integration Test

Untuk menjalankan automated test suite di local:

```bash
npm test
```

Test suite mencakup:
- Health check
- Create, update, delete transaction validations
- Cross-category validation
- Receipt scanning upload filters (MIME type, file size limit, magic bytes)
- Gemini schema post-validation
- In-memory rate limiting

---

## 10. Panduan Push ke GitHub

Pastikan file sensitif (`.env`) tidak terunggah ke repository:

1. **Inisialisasi & Commit:**
   ```bash
   git init
   git add .
   git commit -m "feat: complete finance app rest api with minio object storage and ai vision"
   ```

2. **Hubungkan ke Remote Repository GitHub:**
   ```bash
   git remote add origin https://github.com/<username>/<repo-name>.git
   git branch -M main
   git push -u origin main
   ```
