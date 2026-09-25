'use strict';

function getHealth(req, res) {
  res.status(200).json({
    success: true,
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
}

module.exports = {
  getHealth,
};
