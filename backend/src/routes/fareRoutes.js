const express = require('express');
const router = express.Router();
const controller = require('../controllers/fareController');

router.post('/calculate', controller.calculate);

module.exports = router;
