const db = require("../db");

exports.checkMedicineSafety = (req, res) => {
  const { medicine_name, dose } = req.body;

  // Validation
  if (!medicine_name || dose === undefined) {
    return res.status(400).json({ message: "Missing required fields" });
  }

  const numericDose = parseFloat(dose);
  if (isNaN(numericDose) || numericDose <= 0) {
    return res.status(400).json({ message: "Dose must be a positive number" });
  }

  const query = "SELECT max_daily_dose, unit FROM medicines WHERE LOWER(name) = LOWER(?)";

  db.query(query, [medicine_name], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });

    if (result.length === 0) {
      return res.status(404).json({ message: "Medicine not found" });
    }

    const maxDose = result[0].max_daily_dose;

    if (numericDose > maxDose) {
      res.json({
        status: "UNSAFE",
        message: "Prescribed dose exceeds safe limit"
      });
    } else {
      res.json({
        status: "SAFE",
        message: "Prescribed dose is within safe limit"
      });
    }
  });
};
