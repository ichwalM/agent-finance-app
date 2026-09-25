# ROLE

Bertindak sebagai **Senior Flutter Engineer, Mobile Product Designer, dan UI/UX Engineer** yang berpengalaman membangun aplikasi fintech production-grade.

Tugasmu adalah membangun / merefactor aplikasi mobile finance menggunakan **Flutter**.

Backend REST API **SUDAH TERSEDIA** dan dokumentasi penggunaan API juga **SUDAH ADA di project**.

Fokus utama pekerjaan ini adalah:

> **membangun pengalaman mobile finance yang sangat polished, modern, unik, responsif, dan terasa dirancang oleh product designer profesional — bukan UI generik hasil AI.**

Jangan mendesain ulang backend atau membuat API baru jika tidak diperlukan.

---

# 1. PRIORITAS UTAMA

Urutan prioritas:

1. UI/UX quality
2. Information hierarchy
3. Mobile usability
4. Visual identity
5. Smooth interaction
6. Code quality
7. Performance
8. API integration
9. Maintainability

API yang tersedia harus dianggap sebagai **source of truth**.

Sebelum membuat UI:

* pelajari struktur project
* baca seluruh dokumentasi API
* identifikasi endpoint yang tersedia
* identifikasi model data
* identifikasi flow aplikasi
* identifikasi state yang diperlukan
* identifikasi screen yang dapat dibangun dari API tersebut

Jangan mengubah kontrak API hanya agar sesuai dengan desain.

UI yang menyesuaikan terhadap API, bukan sebaliknya.

---

# 2. DESIGN DIRECTION

Saya TIDAK ingin aplikasi finance yang terlihat seperti template fintech biasa.

Hindari tampilan seperti:

* dashboard template
* UI hasil generator AI
* Dribbble clone
* crypto dashboard generik
* SaaS dashboard yang dipindahkan ke mobile

Saya ingin visual yang memiliki **identitas kuat dan intentional design**.

Gunakan pendekatan:

**Modern Editorial Finance × Minimalist Utility × Contemporary Mobile UI**

Karakter desain:

* sophisticated
* clean
* confident
* sedikit experimental
* editorial
* data-focused
* minimal tetapi tidak kosong
* premium tetapi tidak berlebihan
* playful hanya pada interaction
* professional untuk aplikasi finance

UI harus terlihat seperti hasil kerja tim product design yang benar-benar memikirkan hierarchy, rhythm, typography, whitespace, interaction dan data visualization.

---

# 3. HINDARI "AI LOOK"

DILARANG menggunakan visual berikut sebagai gaya utama:

* excessive gradients
* purple-blue AI gradient
* neon gradient
* mesh gradient
* glassmorphism berlebihan
* glowing border
* glowing button
* floating translucent card dimana-mana
* semua komponen berbentuk rounded card
* border radius berlebihan
* shadow besar di setiap komponen
* icon berwarna-warni tanpa sistem
* dashboard grid monoton
* hero card gradient besar
* decorative blobs
* background dengan random circles
* ilustrasi abstrak AI
* warna cyan-purple sebagai default
* layout yang terlihat seperti template Flutter UI Kit

Gradient hanya boleh digunakan jika memiliki alasan visual yang kuat.

Default-nya:

**jangan gunakan gradient.**

---

# 4. VISUAL LANGUAGE

Gunakan visual language yang lebih berani melalui:

### Typography

Typography harus menjadi elemen desain utama.

Gunakan hierarchy yang kuat antara:

* balance
* nominal transaksi
* heading
* label
* metadata
* caption
* statistics

Nominal uang harus memiliki treatment typography yang khas.

Gunakan tabular figures jika memungkinkan sehingga angka terlihat stabil ketika berubah.

Contoh hierarchy:

Rp 12.450.000

bisa jauh lebih dominan daripada:

Total Balance

Jangan membuat semua text memiliki visual weight yang sama.

---

# 5. COLOR SYSTEM

Gunakan palet warna restrained.

Base:

* warm white / off-white
* charcoal / near black
* subtle neutral gray

Kemudian gunakan **1 primary accent color** yang memiliki karakter.

Contohnya:

* electric lime
* vermilion
* deep cobalt
* rich orange
* emerald

Pilih SATU yang paling cocok dengan keseluruhan visual.

Gunakan warna semantic secara konsisten:

Income → positive

Expense → negative

Warning → warning

Neutral transaction → neutral

Jangan menjadikan seluruh interface penuh warna.

Gunakan warna sebagai **information signal**, bukan decoration.

---

# 6. LAYOUT PRINCIPLES

Jangan membungkus setiap bagian menggunakan Card.

Gunakan kombinasi:

* typography
* spacing
* divider
* section grouping
* background contrast
* thin border
* intentional alignment

untuk membangun hierarchy.

Card hanya digunakan jika memang sebuah elemen membutuhkan container.

Gunakan:

* asymmetric composition jika cocok
* strong vertical rhythm
* generous tetapi controlled spacing
* edge-to-edge section
* horizontal scrolling untuk informasi tertentu
* layered information hierarchy

Jangan hanya menggunakan pola:

Column
→ Card
→ Card
→ Card
→ Card

---

# 7. HOME / DASHBOARD

Home screen jangan menjadi dashboard template.

Saya ingin halaman pertama terasa seperti **personal finance cockpit**.

Prioritas informasi:

1. financial position
2. current balance
3. recent spending behaviour
4. cash flow
5. important transaction/activity
6. quick action

Contoh struktur konseptual:

Header
Personal greeting / current period

Large financial balance

Small contextual insight:
"12% lower spending than last week"

Income / Expense comparison

Interactive spending visualization

Recent activity

Quick transaction action

Tetapi JANGAN mengikuti struktur ini secara kaku.

Gunakan data API untuk menentukan hierarchy yang paling masuk akal.

---

# 8. DATA VISUALIZATION

Karena ini aplikasi finance, visualization merupakan bagian penting desain.

Gunakan chart hanya jika meningkatkan pemahaman.

Contoh:

* spending trend
* income vs expense
* category distribution
* daily spending
* monthly cash flow

Hindari:

* chart penuh warna
* pie chart tradisional jika tidak diperlukan
* legend terlalu banyak
* grafik dekoratif yang tidak memberikan informasi

Prefer:

* minimal line chart
* area sparingly
* bar visualization
* progress / proportional visualization
* compact sparkline

Chart harus terasa native dengan keseluruhan desain.

---

# 9. TRANSACTION LIST

Transaction list merupakan salah satu komponen paling penting.

Jangan membuat transaction:

Card
Card
Card
Card

Gunakan list yang compact dan mudah discan.

Hierarchy:

merchant/category
sub-category
date/time
amount
transaction type

Amount harus mudah dibedakan antara:

income
expense

Gunakan divider / whitespace daripada banyak container.

Tambahkan interaction:

* swipe action jika sesuai
* tap detail
* contextual menu
* filtering
* search
* grouping by date

Contoh grouping:

TODAY

Coffee
Food & Drink                  - Rp 35.000

Salary
Income                       + Rp 8.500.000

YESTERDAY

...

Tetap sesuaikan dengan data API sebenarnya.

---

# 10. ADD TRANSACTION

Flow menambahkan transaksi harus sangat cepat.

Target:

user bisa mencatat transaksi hanya dalam beberapa interaction.

Prioritaskan:

Amount

kemudian:

type
category
sub-category
date
description

Amount input harus menjadi visual focus.

Gunakan numeric keyboard.

Berikan feedback yang jelas setelah transaksi berhasil.

Jangan membuat form panjang seperti form website.

Gunakan mobile-first interaction.

---

# 11. MICROINTERACTION

Gunakan animation untuk meningkatkan UX, bukan sekadar decoration.

Gunakan:

* subtle page transitions
* animated number changes
* smooth chart transitions
* transaction insertion animation
* filter transition
* pressed state
* bottom sheet transition
* modal transition
* skeleton loading
* subtle haptic feedback jika relevan

Animation:

150–350ms

Gunakan motion curve yang natural.

Hindari:

* bounce berlebihan
* animation terlalu lambat
* flashy transition
* animation hanya agar terlihat keren

---

# 12. NAVIGATION

Pilih navigation pattern berdasarkan fitur sebenarnya.

Kemungkinan:

Bottom Navigation:

Home
Transactions
Analytics
Profile

dan sebuah contextual action untuk:

Add Transaction

Tetapi jangan otomatis menggunakan pattern ini.

Analisis terlebih dahulu fitur yang tersedia dari dokumentasi API.

Jika navigation architecture lain lebih masuk akal, gunakan itu.

Navigation harus tetap sederhana.

---

# 13. EMPTY / ERROR / LOADING STATE

Jangan hanya fokus pada happy path.

Implementasikan:

Loading
Empty
Error
Offline
No transaction
No analytics data

Empty state harus tetap mengikuti visual language aplikasi.

Jangan menggunakan ilustrasi AI generik.

Prefer:

typography
simple icon
minimal geometry

---

# 14. DARK MODE

Jika memungkinkan, siapkan architecture sehingga mendukung:

Light Mode
Dark Mode

Dark mode bukan hanya:

white → black.

Perhatikan:

surface hierarchy
contrast
semantic colors
chart readability
divider
text hierarchy

Gunakan ThemeData / ColorScheme dengan benar.

---

# 15. FLUTTER ARCHITECTURE

Gunakan arsitektur Flutter yang maintainable.

Pisahkan minimal:

core/
design_system/
data/
models/
services/
repositories/
features/
widgets/

Gunakan feature-based architecture jika project memungkinkan.

Contoh:

lib/

core/

design_system/
colors/
typography/
spacing/
components/

features/

```
dashboard/
transactions/
analytics/
profile/
```

data/

services/

Jangan over-engineering.

---

# 16. DESIGN SYSTEM

Jangan hardcode style berulang di setiap widget.

Bangun mini design system.

Minimal mempunyai:

AppColors

AppTypography

AppSpacing

AppRadius

AppTheme

Reusable component:

AppButton
AmountText
TransactionItem
SectionHeader
AppBottomSheet
FilterChip
MetricDisplay
EmptyState
LoadingState

Tetapi jangan membuat abstraction yang tidak diperlukan.

---

# 17. RESPONSIVE DESIGN

UI harus bekerja pada berbagai ukuran device.

Pertimbangkan:

small Android
standard Android
large phone
iPhone

Jangan membuat layout berdasarkan fixed width.

Gunakan:

MediaQuery
LayoutBuilder
Flexible
Expanded

dengan tepat.

Perhatikan:

SafeArea
keyboard
bottom inset
notch
dynamic text

---

# 18. API INTEGRATION

Baca dokumentasi API yang sudah tersedia.

Jangan mock data jika endpoint tersedia.

Implementasikan API dengan:

timeout
error handling
loading state
response validation
model parsing

Pisahkan network layer dari UI.

UI tidak boleh langsung memanggil HTTP request.

Gunakan repository/service architecture yang sederhana.

Pertahankan API contract yang sudah ada.

---

# 19. STATE MANAGEMENT

Periksa terlebih dahulu state management yang sudah digunakan project.

Jika sudah ada:

PERTAHANKAN.

Jangan mengganti library hanya karena preferensi pribadi.

Jika project belum memiliki state management, gunakan solusi sederhana dan maintainable seperti:

Riverpod

atau solusi Flutter modern yang paling cocok dengan skala project.

Jangan over-engineering state.

---

# 20. ICON

Gunakan satu icon system secara konsisten.

Hindari mencampur:

Material Icon
Lucide
Phosphor
Cupertino

tanpa alasan.

Prefer icon yang:

minimal
clean
consistent stroke

Jika memungkinkan gunakan:

Lucide
Phosphor

atau icon family lain yang cocok dengan visual direction.

---

# 21. DETAIL YANG MEMBUAT UI TERASA HUMAN-DESIGNED

Perhatikan detail kecil seperti:

baseline text
alignment nominal
spacing antar section
kerning
icon optical alignment
touch target
divider opacity
pressed state
scroll behaviour
keyboard behaviour
loading skeleton
number formatting
date formatting
currency formatting

Gunakan format Rupiah yang benar:

Rp 1.250.000

bukan:

Rp1,250,000.00

jika aplikasi memang menggunakan IDR.

---

# 22. JANGAN MEMAKSA SEMUA HAL MENJADI COMPONENT

Prioritaskan clarity.

Jika widget hanya digunakan sekali dan sederhana, tidak perlu dibuat abstraction yang kompleks.

Clean architecture bukan berarti membuat 20 layer untuk satu screen.

---

# 23. WORKFLOW WAJIB

Jangan langsung coding secara membabi buta.

Lakukan tahapan berikut.

## STEP 1 — PROJECT DISCOVERY

Audit project:

* Flutter version
* folder structure
* dependencies
* navigation
* state management
* existing UI
* API service
* documentation
* models
* endpoint

## STEP 2 — API MAPPING

Buat mapping:

Endpoint
→ Data
→ Feature
→ Screen
→ UI Component

## STEP 3 — UX ARCHITECTURE

Tentukan:

screen hierarchy
navigation
primary user flow
secondary flow

## STEP 4 — DESIGN SYSTEM

Definisikan:

colors
typography
spacing
radius
component behaviour

sebelum membangun banyak screen.

## STEP 5 — IMPLEMENTATION

Bangun dari:

foundation
→ reusable component
→ primary screen
→ secondary screen
→ API integration
→ interaction
→ polish

## STEP 6 — POLISH

Setelah functionality selesai, audit kembali:

spacing
typography
animation
touch target
loading
error
empty state
overflow
responsive behaviour

Jangan berhenti hanya karena "sudah berjalan".

---

# 24. VISUAL QUALITY CHECK

Setiap selesai membuat screen, tanyakan:

> Apakah desain ini terlihat seperti hasil Flutter UI kit / AI generator?

Jika jawabannya iya:

refactor.

Periksa khusus:

* terlalu banyak card?
* terlalu banyak rounded rectangle?
* terlalu banyak gradient?
* terlalu banyak warna?
* hierarchy text terlalu datar?
* spacing monoton?
* terlalu simetris?
* terlihat seperti dashboard template?
* tombol terlalu generik?
* semua informasi dimasukkan container?

Jika iya, sederhanakan dan buat composition lebih intentional.

---

# 25. DESIGN PHILOSOPHY

Ingat prinsip utama:

**Hierarchy > Decoration**

**Typography > Gradient**

**Spacing > Shadow**

**Information > Ornament**

**Interaction > Animation gimmick**

**Consistency > Novelty**

**Clarity > Complexity**

Aplikasi harus menarik karena:

composition,
typography,
interaction,
information hierarchy,
dan detail,

bukan karena gradient dan efek visual.

---

# 26. PRODUCT FEEL

Target akhirnya adalah aplikasi yang terasa seperti:

produk fintech independen modern dengan identitas visual sendiri,

bukan:

"Flutter Finance App Template".

User harus merasakan bahwa aplikasi ini sengaja dirancang khusus untuk produknya.

---

# FINAL INSTRUCTION

Sekarang:

1. pelajari seluruh project terlebih dahulu
2. baca dokumentasi API
3. pahami existing code
4. jangan merusak functionality yang sudah ada
5. tentukan UX architecture berdasarkan API
6. bangun design system
7. implementasikan UI secara bertahap
8. integrasikan API yang sudah ada
9. lakukan visual polish
10. periksa seluruh screen untuk overflow/error
11. jalankan lint/analyze/test/build jika tersedia
12. perbaiki semua masalah sebelum menyatakan selesai

Jangan hanya memberikan rekomendasi atau mockup.

**Implementasikan langsung ke codebase.**

Jika terdapat keputusan kecil mengenai UI/UX, ambil keputusan sendiri sebagai Senior Product Designer tanpa terus meminta konfirmasi.

Gunakan judgement terbaikmu untuk menghasilkan aplikasi finance Flutter yang memiliki identitas kuat, usable, premium, dan tidak terlihat seperti hasil template maupun AI-generated design.
