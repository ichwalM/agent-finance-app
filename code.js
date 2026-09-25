const SPREADSHEET_ID = "1OiP9IE4D8tfB1uR-qz31f0MGI_kweGbiaG3BvDm1tfs";
const SHEET_NAME = "Log_Pengeluaran"; // Sesuai dengan nama tab sheet

function getSheet() {
  const ss = SPREADSHEET_ID
    ? SpreadsheetApp.openById(SPREADSHEET_ID)
    : SpreadsheetApp.getActiveSpreadsheet();

  if (!ss) {
    throw new Error("Spreadsheet tidak ditemukan. Pastikan SPREADSHEET_ID terisi atau script terhubung ke spreadsheet.");
  }

  let sheet = ss.getSheetByName(SHEET_NAME);
  if (!sheet) {
    sheet = ss.getSheets()[0];
  }
  return sheet;
}

// Fungsi pembantu untuk mencari baris terakhir data (berdasarkan Kolom B / Tanggal)
function getActualLastRow(sheet) {
  // Mengecek nilai di Kolom B mulai dari baris 4 ke bawah
  const maxRows = sheet.getMaxRows();
  const values = sheet.getRange(4, 2, maxRows - 3, 1).getValues();
  for (let i = values.length - 1; i >= 0; i--) {
    if (values[i][0] !== "" && values[i][0] !== null) {
      return i + 4; // Mengembalikan nomor baris sebenarnya di sheet
    }
  }
  return 3; // Jika belum ada data (hanya header di baris 3)
}

// 1. GET: Mengambil riwayat transaksi (Kolom B:F, mulai Baris 4)
function doGet(e) {
  try {
    const sheet = getSheet();
    const lastRow = getActualLastRow(sheet);

    // Jika belum ada data transaksi (hanya header di baris 3)
    if (lastRow <= 3) {
      return jsonResponse({ status: "success", data: [] });
    }

    // Ambil data dari baris 4, kolom 2 (Kolom B), sebanyak (lastRow - 3) baris dan 5 kolom (B, C, D, E, F)
    const rows = sheet.getRange(4, 2, lastRow - 3, 5).getValues();
    const data = rows.map((row, index) => ({
      row: index + 4, // Baris asli di Google Sheets (mulai baris 4)
      tanggal: formatDate(row[0]),
      kategori: row[1],
      sub_kategori: row[2],
      deskripsi: row[3],
      nominal: Number(row[4])
    }));

    return jsonResponse({ status: "success", data: data });
  } catch (err) {
    return jsonResponse({ status: "error", message: err.toString() });
  }
}

// 2. POST: Create, Update, Delete
function doPost(e) {
  try {
    const sheet = getSheet();

    if (!e || !e.postData || !e.postData.contents) {
      throw new Error("Payload request kosong");
    }

    const payload = JSON.parse(e.postData.contents);
    const action = payload.action;

    // CREATE: Menambahkan transaksi baru di kolom B:F
    if (action === "create") {
      const targetRow = getActualLastRow(sheet) + 1;
      
      // Menulis nilai tepat di baris target, kolom 2 (B) sampai kolom 6 (F)
      sheet.getRange(targetRow, 2, 1, 5).setValues([[
        payload.tanggal,
        payload.kategori,
        payload.sub_kategori,
        payload.deskripsi,
        Number(payload.nominal)
      ]]);

      return jsonResponse({
        status: "success",
        message: "Transaksi berhasil dicatat",
        row: targetRow
      });
    }

    // UPDATE: Memperbarui data pada baris tertentu di kolom B:F
    if (action === "update") {
      const row = Number(payload.row);
      const lastRow = getActualLastRow(sheet);
      
      if (!row || row < 4 || row > lastRow) {
        throw new Error("Nomor row tidak valid untuk update (data dimulai dari row 4)");
      }

      sheet.getRange(row, 2, 1, 5).setValues([[
        payload.tanggal,
        payload.kategori,
        payload.sub_kategori,
        payload.deskripsi,
        Number(payload.nominal)
      ]]);

      return jsonResponse({
        status: "success",
        message: "Transaksi berhasil diubah",
        row: row
      });
    }

    // DELETE: Menghapus data transaksi
    if (action === "delete") {
      const row = Number(payload.row);
      const lastRow = getActualLastRow(sheet);
      
      if (!row || row < 4 || row > lastRow) {
        throw new Error("Nomor row tidak valid untuk delete (data dimulai dari row 4)");
      }

      // Opsi 1: Kosongkan isi kolom B sampai F agar dropdown/formatting baris tetap rapi
      sheet.getRange(row, 2, 1, 5).clearContent();
      
      // Catatan: Jika ingin menghapus seluruh baris fisik, gunakan:
      // sheet.deleteRow(row);

      return jsonResponse({
        status: "success",
        message: "Transaksi berhasil dihapus",
        row: row
      });
    }

    throw new Error("Action tidak dikenali: " + action);
  } catch (err) {
    return jsonResponse({ status: "error", message: err.toString() });
  }
}

function formatDate(val) {
  if (val instanceof Date) {
    return Utilities.formatDate(val, "Asia/Makassar", "yyyy-MM-dd");
  }
  return String(val);
}

function jsonResponse(data) {
  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}