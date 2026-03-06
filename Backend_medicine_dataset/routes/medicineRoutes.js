const express = require("express");
const router = express.Router();
const controller = require("../controllers/medicineController");

// Single medicine safety check
router.post("/check", controller.checkMedicineSafety);

// OCR prescription analysis for overdose detection
router.post("/analyze-prescription", controller.analyzePrescriptionOCR);

module.exports = router;
