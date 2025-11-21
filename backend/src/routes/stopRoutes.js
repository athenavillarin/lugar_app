const express = require('express');
const router = express.Router();
const controller = require('../controllers/stopsController');

router.get('/', controller.list);

module.exports = router;
