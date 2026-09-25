'use strict';

const { z } = require('zod');
const { CATEGORY_SUB_CATEGORIES, ALLOWED_CATEGORIES } = require('../constants/categories');
const {
  isValidCalendarDate,
  nominalSchema,
  deskripsiSchema,
} = require('./transaction.schema');

const receiptResultSchema = z
  .object({
    tanggal: z
      .string({
        required_error: 'tanggal tidak ditemukan dalam hasil scan',
        invalid_type_error: 'tanggal harus berupa string',
      })
      .refine(isValidCalendarDate, {
        message: 'tanggal dari struk tidak valid secara kalender (harus format YYYY-MM-DD)',
      }),
    nominal: nominalSchema,
    kategori: z.enum(ALLOWED_CATEGORIES, {
      errorMap: () => ({
        message: `kategori harus salah satu dari: ${ALLOWED_CATEGORIES.join(', ')}`,
      }),
    }),
    sub_kategori: z
      .string({
        required_error: 'sub_kategori wajib diisi',
        invalid_type_error: 'sub_kategori harus berupa string',
      })
      .trim()
      .min(1, 'sub_kategori tidak boleh kosong'),
    deskripsi: deskripsiSchema,
  })
  .superRefine((data, ctx) => {
    const validSubs = CATEGORY_SUB_CATEGORIES[data.kategori];
    if (!validSubs || !validSubs.includes(data.sub_kategori)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['sub_kategori'],
        message: `sub_kategori '${data.sub_kategori}' tidak sesuai dengan kategori '${data.kategori}'`,
      });
    }
  });

module.exports = {
  receiptResultSchema,
};
