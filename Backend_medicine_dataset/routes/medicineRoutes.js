const express = require("express");
const router = express.Router();
const controller = require("../controllers/medicineController");

router.post("/check", controller.checkMedicineSafety);

module.exports = router;
