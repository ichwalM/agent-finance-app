'use strict';

const { z } = require('zod');
const { CATEGORY_SUB_CATEGORIES, ALLOWED_CATEGORIES } = require('../constants/categories');

/**
 * Validates that a string is a calendar-valid date in YYYY-MM-DD format.
 */
function isValidCalendarDate(val) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(val)) {
    return false;
  }
  const [yearStr, monthStr, dayStr] = val.split('-');
  const year = parseInt(yearStr, 10);
  const month = parseInt(monthStr, 10);
  const day = parseInt(dayStr, 10);

  if (month < 1 || month > 12) {
    return false;
  }

  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

const dateSchema = z
  .string({
    required_error: 'tanggal wajib diisi',
    invalid_type_error: 'tanggal harus berupa string format YYYY-MM-DD',
  })
  .refine(isValidCalendarDate, {
    message: 'tanggal harus berupa tanggal kalender yang valid dengan format YYYY-MM-DD',
  });

const kategoriSchema = z.enum(ALLOWED_CATEGORIES, {
  errorMap: () => ({
    message: `kategori harus salah satu dari: ${ALLOWED_CATEGORIES.join(', ')}`,
  }),
});

const nominalSchema = z
  .number({
    required_error: 'nominal wajib diisi',
    invalid_type_error: 'nominal harus berupa number',
  })
  .refine((val) => Number.isFinite(val) && val > 0, {
    message: 'nominal harus berupa angka positif, finite, dan lebih besar dari 0',
  });

const deskripsiSchema = z
  .string({
    required_error: 'deskripsi wajib diisi',
    invalid_type_error: 'deskripsi harus berupa string',
  })
  .trim()
  .min(1, 'deskripsi tidak boleh kosong')
  .max(255, 'deskripsi maksimal 255 karakter');

const createTransactionSchema = z
  .object({
    tanggal: dateSchema,
    kategori: kategoriSchema,
    sub_kategori: z
      .string({
        required_error: 'sub_kategori wajib diisi',
        invalid_type_error: 'sub_kategori harus berupa string',
      })
      .trim()
      .min(1, 'sub_kategori tidak boleh kosong'),
    deskripsi: deskripsiSchema,
    nominal: nominalSchema,
  })
  .strict({
    message: 'Request body contains disallowed fields',
  })
  .superRefine((data, ctx) => {
    const validSubs = CATEGORY_SUB_CATEGORIES[data.kategori];
    if (!validSubs || !validSubs.includes(data.sub_kategori)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['sub_kategori'],
        message: `sub_kategori '${data.sub_kategori}' tidak valid untuk kategori '${data.kategori}'. Pilihan yang diperbolehkan: ${validSubs ? validSubs.join(', ') : 'tidak ada'}`,
      });
    }
  });

const updateTransactionSchema = createTransactionSchema;

const rowParamSchema = z.object({
  row: z.coerce
    .number({
      required_error: 'row parameter wajib diisi',
      invalid_type_error: 'row parameter harus berupa angka',
    })
    .int('row parameter harus berupa integer')
    .positive('row parameter harus berupa integer positif (> 0)'),
});

module.exports = {
  createTransactionSchema,
  updateTransactionSchema,
  rowParamSchema,
  isValidCalendarDate,
  dateSchema,
  kategoriSchema,
  nominalSchema,
  deskripsiSchema,
};
