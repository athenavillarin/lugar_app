const express = require('express');
const router = express.Router();
const controller = require('../controllers/favoritesController');

router.post('/', controller.add);

module.exports = router;
