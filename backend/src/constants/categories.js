'use strict';

const CATEGORIES = Object.freeze({
  NEEDS: 'Needs',
  WANTS: 'Wants',
  SIMPANAN: 'Simpanan',
  INVESTASI: 'Investasi',
});

const CATEGORY_SUB_CATEGORIES = Object.freeze({
  [CATEGORIES.NEEDS]: Object.freeze([
    'Sewa Kost',
    'Makan & Minum',
    'Transport & Bensin',
    'Internet & Kuota',
    'Internet/Kuota',
  ]),
  [CATEGORIES.WANTS]: Object.freeze([
    'Kopi & Nongkrong',
    'Jajan & Hiburan',
    'Kopi & Jajan',
  ]),
  [CATEGORIES.SIMPANAN]: Object.freeze([
    'Dana Darurat',
  ]),
  [CATEGORIES.INVESTASI]: Object.freeze([
    'RDPU / Saham / Emas',
    'Portofolio Investasi',
  ]),
});

const ALLOWED_CATEGORIES = Object.freeze(Object.keys(CATEGORY_SUB_CATEGORIES));

module.exports = {
  CATEGORIES,
  CATEGORY_SUB_CATEGORIES,
  ALLOWED_CATEGORIES,
};
