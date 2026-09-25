Bertindaklah sebagai **Senior Backend Engineer, API Architect, DevOps Engineer, dan Security Engineer**.

Tugasmu adalah membangun **backend REST API production-ready** untuk aplikasi pencatatan keuangan pribadi saya. Backend akan berjalan di **home server menggunakan Docker dan Docker Compose**.

Backend berfungsi sebagai API Gateway antara:

```text
Mobile App
    │
    ▼
Backend REST API
    │
    ├── Google Apps Script → Google Sheets
    │
    └── Google Gemini Vision API → Receipt Scanner
```

Prioritas utama:

1. Reliability
2. Security
3. Maintainability
4. Simplicity
5. Observability
6. Performance
7. Docker deployment yang ringan

Jangan melakukan over-engineering.

Gunakan salah satu stack berikut dan pilih yang menurutmu paling sederhana serta reliable:

* Node.js + Express
* Python + FastAPI

Jangan membuat implementasi untuk kedua stack sekaligus.

Setelah memilih stack, jelaskan secara singkat alasan pemilihannya dan langsung implementasikan project secara lengkap.

---

# 1. Arsitektur Service

Backend bertindak sebagai API Gateway antara:

```text
Mobile Application
       │
       ▼
REST API Backend
       │
       ├──────────────► Google Apps Script
       │                     │
       │                     ▼
       │                Google Sheets
       │
       └──────────────► Google Gemini API
                              │
                              ▼
                       Receipt Analysis
```

Mobile application **tidak boleh berkomunikasi langsung** dengan Gemini API.

`GEMINI_API_KEY` hanya boleh berada di backend dan tidak boleh pernah dikirim ke client.

---

# 2. Google Apps Script

Google Apps Script Web App:

```text
https://script.google.com/macros/s/AKfycbw9hjsnm4qsZWxOjbrx2UVxJVlS09DJ2l8f3bcpMeZS13zwezLWftsuQt_U76CyX8y0NA/exec
```

URL tersebut **jangan di-hardcode di source code**.

Ambil melalui environment variable:

```env
GAS_URL=
```

## GET

Apps Script mendukung:

```http
GET GAS_URL
```

untuk mengambil semua riwayat transaksi.

Backend harus meneruskannya melalui:

```http
GET /api/transactions
```

---

## POST

Semua operasi create, update, dan delete ke Google Apps Script dilakukan menggunakan HTTP POST.

Saat melakukan request ke Google Apps Script gunakan:

```http
Content-Type: text/plain;charset=utf-8
```

dan kirim body dalam bentuk serialized JSON.

### Create

```json
{
  "action": "create",
  "tanggal": "YYYY-MM-DD",
  "kategori": "...",
  "sub_kategori": "...",
  "deskripsi": "...",
  "nominal": 12345
}
```

### Update

```json
{
  "action": "update",
  "row": 4,
  "tanggal": "YYYY-MM-DD",
  "kategori": "...",
  "sub_kategori": "...",
  "deskripsi": "...",
  "nominal": 12345
}
```

### Delete

```json
{
  "action": "delete",
  "row": 4
}
```

Buat helper/service khusus untuk komunikasi ke Google Apps Script agar logic request tidak tersebar di controller.

Contoh:

```text
services/
└── googleSheetsService
```

atau struktur yang setara sesuai stack yang dipilih.

---

# 3. Endpoint REST API

Base URL:

```text
/api
```

Implementasikan endpoint berikut.

---

## GET /api/health

Digunakan untuk health check server/container.

Response minimal:

```json
{
  "success": true,
  "status": "ok",
  "timestamp": "ISO-8601"
}
```

Jangan memanggil Gemini atau Google Sheets dari endpoint ini.

Endpoint harus cepat dan bisa digunakan Docker healthcheck/reverse proxy.

---

## GET /api/transactions

Proxy data transaksi dari Google Apps Script.

Flow:

```text
Mobile
   ↓
GET /api/transactions
   ↓
Backend
   ↓
GET GAS_URL
   ↓
Google Apps Script
   ↓
Backend
   ↓
Mobile
```

Tangani:

* timeout
* Google Apps Script unavailable
* invalid JSON response
* network error
* HTTP non-2xx response

Jangan membocorkan stack trace atau detail internal ke client.

---

## POST /api/transactions

Membuat transaksi baru.

Client mengirim:

```json
{
  "tanggal": "2026-09-25",
  "kategori": "Needs",
  "sub_kategori": "Makan & Minum",
  "deskripsi": "Alfamart",
  "nominal": 25000
}
```

Backend harus otomatis menambahkan:

```json
{
  "action": "create"
}
```

sebelum request diteruskan ke Google Apps Script.

Client tidak perlu dan tidak boleh menentukan `action`.

---

## PUT /api/transactions/:row

Mengubah transaksi.

Contoh:

```http
PUT /api/transactions/4
```

Body:

```json
{
  "tanggal": "2026-09-25",
  "kategori": "Needs",
  "sub_kategori": "Makan & Minum",
  "deskripsi": "Indomaret",
  "nominal": 30000
}
```

Backend harus inject:

```json
{
  "action": "update",
  "row": 4
}
```

Validasi `row`:

* wajib integer
* harus > 0
* reject nilai invalid

---

## DELETE /api/transactions/:row

Contoh:

```http
DELETE /api/transactions/4
```

Backend meneruskan ke Apps Script:

```json
{
  "action": "delete",
  "row": 4
}
```

Validasi `row`.

---

# 4. Receipt Scanner dengan Gemini Vision

Endpoint:

```http
POST /api/scan-receipt
```

Content-Type:

```http
multipart/form-data
```

Field upload:

```text
receipt
```

Contoh:

```text
receipt=<image>
```

File yang diperbolehkan:

```text
image/jpeg
image/png
image/webp
```

Maximum file size:

```text
5 MB
```

File selain tipe tersebut harus ditolak.

Jangan hanya memvalidasi berdasarkan extension filename.

Validasi MIME type dari upload.

Sebisa mungkin gunakan **memory buffer** dan jangan menyimpan file secara permanen ke disk karena file hanya dibutuhkan sementara untuk dikirim ke Gemini.

Setelah request selesai, gambar tidak boleh disimpan oleh backend.

---

# 5. Gemini Configuration

API key:

```env
GEMINI_API_KEY=
```

Model jangan di-hardcode di banyak tempat.

Gunakan environment variable:

```env
GEMINI_MODEL=gemini-1.5-flash
```

Jika SDK Gemini yang digunakan memiliki API/model naming terbaru, gunakan implementasi yang kompatibel dengan SDK tersebut tanpa mengubah behavior aplikasi.

Pisahkan komunikasi Gemini ke service:

```text
services/
└── geminiService
```

---

# 6. Gemini System Instruction

Gunakan instruction/prompt kurang lebih seperti berikut:

````text
Anda adalah AI receipt parser untuk aplikasi personal finance.

Analisis gambar struk yang diberikan.

Ekstrak transaksi utama dari struk tersebut dan kembalikan HANYA structured JSON sesuai schema yang diberikan.

Jangan mengarang informasi yang tidak terlihat pada struk.

Kategori yang diperbolehkan:

Needs:
- Sewa Kost
- Makan & Minum
- Transport & Bensin
- Internet & Kuota

Wants:
- Kopi & Nongkrong
- Jajan & Hiburan

Simpanan:
- Dana Darurat

Investasi:
- RDPU / Saham / Emas

Aturan:

1. tanggal harus menggunakan format YYYY-MM-DD.
2. nominal adalah total pembayaran akhir pada struk.
3. nominal harus berupa number tanpa simbol mata uang dan separator ribuan.
4. kategori hanya boleh salah satu:
   - Needs
   - Wants
   - Simpanan
   - Investasi
5. sub_kategori harus sesuai daftar kategori yang diperbolehkan.
6. deskripsi sebaiknya berisi nama merchant/toko.
7. Jika nama toko tidak jelas, gunakan ringkasan isi transaksi.
8. Jangan menambahkan property selain schema yang ditentukan.
9. Jangan mengembalikan Markdown.
10. Jangan mengembalikan ```json.
11. Jangan memberikan penjelasan tambahan.
````

---

# 7. Structured JSON Output

Gunakan fitur Structured Output / JSON Schema dari Gemini jika SDK/model mendukungnya.

Schema:

```json
{
  "tanggal": "YYYY-MM-DD",
  "nominal": 25000,
  "kategori": "Needs",
  "sub_kategori": "Makan & Minum",
  "deskripsi": "Alfamart"
}
```

Secara konseptual schema harus memastikan:

```text
tanggal      → string
nominal      → number
kategori     → enum
sub_kategori → string
deskripsi    → string
```

Kategori harus dibatasi menjadi:

```text
Needs
Wants
Simpanan
Investasi
```

Setelah Gemini mengembalikan response, **backend tetap wajib melakukan validation sendiri**.

Jangan menganggap output AI selalu valid.

Jika AI memberikan:

* malformed JSON
* kategori invalid
* nominal invalid
* tanggal invalid
* response kosong

maka backend harus mengembalikan error yang aman dan jelas.

---

# 8. Behavior Scan Receipt

Flow:

```text
Mobile App
    │
    │ multipart image
    ▼
POST /api/scan-receipt
    │
    ▼
Validate File
    │
    ▼
Gemini Vision
    │
    ▼
Structured JSON
    │
    ▼
Validate Result
    │
    ▼
Return JSON to Mobile
```

PENTING:

Endpoint ini **TIDAK BOLEH langsung menyimpan transaksi ke Google Sheets**.

Flow aplikasi adalah:

```text
Scan receipt
      ↓
AI extraction
      ↓
Return JSON
      ↓
User melihat hasil
      ↓
User edit jika perlu
      ↓
User menekan Save
      ↓
POST /api/transactions
      ↓
Google Sheets
```

---

# 9. Validation

Gunakan validation library yang sesuai stack.

Contoh:

Node.js:

```text
Zod
Joi
Valibot
```

Python:

```text
Pydantic
```

Validation transaction minimal:

### tanggal

Format:

```text
YYYY-MM-DD
```

Harus valid secara kalender.

### kategori

Enum:

```text
Needs
Wants
Simpanan
Investasi
```

### sub_kategori

Harus konsisten dengan kategori.

Mapping:

```text
Needs
 ├── Sewa Kost
 ├── Makan & Minum
 ├── Transport & Bensin
 └── Internet & Kuota

Wants
 ├── Kopi & Nongkrong
 └── Jajan & Hiburan

Simpanan
 └── Dana Darurat

Investasi
 └── RDPU / Saham / Emas
```

Contoh berikut harus ditolak:

```json
{
  "kategori": "Needs",
  "sub_kategori": "Kopi & Nongkrong"
}
```

### nominal

Harus:

```text
number
> 0
finite
```

Jangan menerima:

```text
NaN
Infinity
negative value
```

### deskripsi

* string
* trim whitespace
* tentukan reasonable maximum length

---

# 10. Standard API Response

Gunakan response yang konsisten.

Successful response:

```json
{
  "success": true,
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request data"
  }
}
```

Jangan mengirim:

* API key
* stack trace
* internal filesystem path
* raw internal exception
* environment variables

ke client.

---

# 11. HTTP Status Code

Gunakan status code dengan benar.

Contoh:

```text
200 OK
201 Created
400 Bad Request
404 Not Found
413 Payload Too Large
415 Unsupported Media Type
422 Unprocessable Entity
429 Too Many Requests
500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
504 Gateway Timeout
```

---

# 12. Error Handling

Buat global error handler.

Tangani minimal:

```text
ValidationError
UploadError
GeminiError
GeminiTimeout
GoogleAppsScriptError
GoogleAppsScriptTimeout
NetworkError
UnknownError
```

Semua upstream HTTP request harus memiliki timeout.

Tidak boleh ada request ke Gemini atau Apps Script yang menggantung tanpa batas waktu.

---

# 13. Security

Implementasikan baseline security yang masuk akal.

Minimal:

* secure HTTP headers
* CORS configuration dari environment variable
* request body limit
* upload limit 5 MB
* input validation
* rate limiting khusus `/api/scan-receipt`
* jangan expose stack trace
* jangan log API key
* jangan log isi environment variable
* jangan commit `.env`
* gunakan least-privilege container
* container sebaiknya berjalan sebagai non-root user

CORS menggunakan:

```env
CORS_ORIGIN=
```

Support beberapa origin jika implementasinya sederhana.

Jangan menggunakan:

```text
Access-Control-Allow-Origin: *
```

sebagai default production.

---

# 14. Rate Limit

Receipt scanner menggunakan API berbayar sehingga perlu rate limiting.

Implementasikan reasonable rate limit khusus:

```text
POST /api/scan-receipt
```

Configuration sebaiknya melalui environment variable.

Contoh:

```env
SCAN_RATE_LIMIT_WINDOW_SECONDS=60
SCAN_RATE_LIMIT_MAX=10
```

Tidak perlu menggunakan Redis untuk project single-instance ini.

In-memory rate limiter cukup.

---

# 15. Logging

Buat structured logging.

Log minimal:

```text
timestamp
level
method
path
status
duration
requestId
```

Jangan log:

```text
GEMINI_API_KEY
image binary
authorization credentials
environment secrets
```

Setiap request sebaiknya memiliki `requestId`.

Jika client memberikan request ID yang valid, boleh digunakan; jika tidak generate sendiri.

---

# 16. Configuration

Semua konfigurasi harus berasal dari environment variable.

Buat `.env.example`:

```env
NODE_ENV=production

PORT=3000

GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-1.5-flash

GAS_URL=https://script.google.com/macros/s/AKfycbw9hjsnm4qsZWxOjbrx2UVxJVlS09DJ2l8f3bcpMeZS13zwezLWftsuQt_U76CyX8y0NA/exec

CORS_ORIGIN=http://localhost:3000

GAS_TIMEOUT_MS=10000
GEMINI_TIMEOUT_MS=30000

SCAN_RATE_LIMIT_WINDOW_SECONDS=60
SCAN_RATE_LIMIT_MAX=10
```

Jika menggunakan Python, boleh sesuaikan nama timeout tanpa mengubah maksudnya.

Application harus melakukan startup validation.

Jika environment wajib seperti:

```text
GEMINI_API_KEY
GAS_URL
```

tidak tersedia, server harus gagal start dengan pesan konfigurasi yang jelas.

Jangan menjalankan aplikasi dalam kondisi konfigurasi setengah valid.

---

# 17. Project Structure

Gunakan struktur project modular dan sederhana.

Contoh Node.js:

```text
backend/
├── src/
│   ├── app.js
│   ├── server.js
│   │
│   ├── config/
│   │   └── env.js
│   │
│   ├── routes/
│   │   ├── health.routes.js
│   │   ├── transactions.routes.js
│   │   └── receipt.routes.js
│   │
│   ├── controllers/
│   │   ├── transactions.controller.js
│   │   └── receipt.controller.js
│   │
│   ├── services/
│   │   ├── googleSheets.service.js
│   │   └── gemini.service.js
│   │
│   ├── schemas/
│   │   ├── transaction.schema.js
│   │   └── receipt.schema.js
│   │
│   ├── middleware/
│   │   ├── error.middleware.js
│   │   ├── upload.middleware.js
│   │   └── requestId.middleware.js
│   │
│   └── utils/
│       └── logger.js
│
├── tests/
│
├── .dockerignore
├── .env.example
├── .gitignore
├── Dockerfile
├── docker-compose.yml
├── package.json
└── README.md
```

Tidak harus mengikuti struktur tersebut secara literal jika stack yang dipilih memiliki convention yang lebih baik.

Hindari struktur enterprise yang terlalu kompleks.

---

# 18. Dockerfile

Buat Dockerfile production-ready.

Requirements:

* image ringan
* gunakan multi-stage build jika memang memberikan manfaat
* dependency production-only pada final image
* aplikasi berjalan menggunakan non-root user
* jangan copy `.env`
* expose port aplikasi
* graceful shutdown SIGTERM/SIGINT
* optimalkan Docker layer caching

Jangan gunakan image unnecessarily besar.

---

# 19. Docker Compose

Buat:

```text
docker-compose.yml
```

Requirements:

```yaml
restart: unless-stopped
```

Expose aplikasi:

```text
3000:3000
```

atau menggunakan environment:

```text
${PORT:-3000}:3000
```

Gunakan:

```yaml
env_file:
  - .env
```

Tambahkan healthcheck menggunakan:

```text
GET /api/health
```

Jangan mount source code sebagai volume dalam production karena aplikasi harus berjalan dari Docker image.

Volume hanya digunakan jika memang ada data persistent yang benar-benar dibutuhkan.

Karena service ini stateless, jangan menambahkan volume yang tidak perlu.

---

# 20. Graceful Shutdown

Backend harus menangani:

```text
SIGTERM
SIGINT
```

agar Docker dapat shutdown container dengan bersih.

Jangan langsung melakukan hard exit jika HTTP server masih menangani request.

---

# 21. Docker Ignore

Buat `.dockerignore`.

Minimal:

```text
.git
.gitignore
.env
node_modules
__pycache__
*.log
tests
README.md
```

Sesuaikan dengan stack.

---

# 22. Git Ignore

Buat `.gitignore`.

Minimal exclude:

```text
.env
node_modules
__pycache__
*.log
.DS_Store
```

sesuaikan dengan stack.

---

# 23. README

Buat README yang menjelaskan:

## Requirements

```text
Docker
Docker Compose
Gemini API Key
Google Apps Script URL
```

## Installation

```bash
cp .env.example .env
```

Edit `.env`.

Kemudian:

```bash
docker compose build
docker compose up -d
```

Check:

```bash
docker compose ps
```

Logs:

```bash
docker compose logs -f
```

Health check:

```bash
curl http://localhost:3000/api/health
```

Stop:

```bash
docker compose down
```

Restart:

```bash
docker compose restart
```

Update setelah source berubah:

```bash
docker compose up -d --build
```

---

# 24. API Usage Examples

README harus memiliki contoh `curl`.

Health:

```bash
curl http://localhost:3000/api/health
```

Transactions:

```bash
curl http://localhost:3000/api/transactions
```

Create:

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

Update:

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

Delete:

```bash
curl -X DELETE http://localhost:3000/api/transactions/4
```

Scan:

```bash
curl -X POST http://localhost:3000/api/scan-receipt \
  -F "receipt=@receipt.jpg"
```

---

# 25. Testing

Tambahkan minimal unit/integration test untuk behavior penting:

```text
GET /api/health

POST /api/transactions:
- valid payload
- invalid kategori
- invalid sub kategori
- negative nominal

PUT /api/transactions/:row:
- invalid row

DELETE /api/transactions/:row:
- invalid row

POST /api/scan-receipt:
- unsupported MIME
- file > 5 MB
- Gemini invalid response
```

External services Gemini dan Google Apps Script boleh di-mock.

Jangan memanggil API asli saat automated test.

---

# 26. Hal yang DILARANG

Jangan:

* menyimpan GEMINI_API_KEY di source code
* mengirim API key ke mobile client
* menyimpan gambar receipt secara permanen
* langsung menyimpan hasil scan ke Google Sheets
* mempercayai output Gemini tanpa validation
* mempercayai input client tanpa validation
* expose stack trace ke client
* menggunakan `latest` dependency secara sembarangan
* menggunakan root container tanpa alasan
* menambahkan Redis/database/message queue yang tidak diperlukan
* menambahkan microservice yang tidak diperlukan
* membuat abstraksi enterprise berlebihan
* menggunakan volume Docker untuk sesuatu yang tidak persistent
* mencampur business logic dengan routing
* hardcode GAS URL di banyak file
* hardcode Gemini model di banyak file

---

# 27. Acceptance Criteria

Project dianggap selesai jika:

1. `docker compose up -d --build` berhasil.
2. Container berstatus healthy.
3. `/api/health` menghasilkan HTTP 200.
4. `/api/transactions` berhasil proxy GET ke Google Apps Script.
5. create transaction berhasil.
6. update transaction berhasil.
7. delete transaction berhasil.
8. receipt JPG/PNG/WebP ≤5 MB dapat diproses Gemini.
9. receipt scanner menghasilkan JSON terstruktur.
10. receipt scan tidak otomatis menyimpan ke Sheets.
11. invalid transaction ditolak.
12. invalid file ditolak.
13. file >5 MB ditolak.
14. error upstream tidak menyebabkan server crash.
15. SIGTERM menghasilkan graceful shutdown.
16. secret tidak berada di source code.
17. container berjalan sebagai non-root.
18. README dapat digunakan untuk deployment dari server kosong yang sudah memiliki Docker.

---

# 28. Cara Kamu Mengerjakan

Jangan hanya memberikan tutorial atau pseudo-code.

Saya ingin kamu **benar-benar membuat project lengkap**.

Urutan pengerjaan:

1. Tentukan stack.
2. Jelaskan arsitektur singkat.
3. Tampilkan final project tree.
4. Implementasikan semua source code.
5. Implementasikan validation.
6. Implementasikan Google Apps Script service.
7. Implementasikan Gemini service.
8. Implementasikan global error handling.
9. Implementasikan security middleware.
10. Implementasikan Dockerfile.
11. Implementasikan Docker Compose.
12. Implementasikan `.env.example`.
13. Implementasikan `.gitignore` dan `.dockerignore`.
14. Implementasikan tests.
15. Buat README.
16. Review ulang seluruh project untuk mencari:

    * bug
    * security issue
    * dependency problem
    * Docker issue
    * inconsistent response
    * missing validation
17. Perbaiki masalah yang ditemukan sebelum menyatakan project selesai.

Jika environment yang digunakan memungkinkan membuat file secara langsung, **buat/edit file project tersebut secara langsung daripada hanya menampilkan potongan kode di chat**.

Jangan berhenti setelah membuat skeleton.

Pastikan hasil akhirnya dapat langsung saya clone/copy ke home server, mengisi `.env`, lalu menjalankan:

```bash
docker compose up -d --build
```

dan backend siap digunakan.
