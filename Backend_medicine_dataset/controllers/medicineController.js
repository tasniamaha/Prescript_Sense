const db = require("../db");

// Levenshtein distance for fuzzy matching
const calculateLevenshteinDistance = (str1, str2) => {
  const track = Array(str2.length + 1)
    .fill(null)
    .map(() => Array(str1.length + 1).fill(0));

  for (let i = 0; i <= str1.length; i += 1) {
    track[0][i] = i;
  }
  for (let j = 0; j <= str2.length; j += 1) {
    track[j][0] = j;
  }

  for (let j = 1; j <= str2.length; j += 1) {
    for (let i = 1; i <= str1.length; i += 1) {
      const indicator = str1[i - 1] === str2[j - 1] ? 0 : 1;
      track[j][i] = Math.min(
        track[j][i - 1] + 1,
        track[j - 1][i] + 1,
        track[j - 1][i - 1] + indicator
      );
    }
  }

  return track[str2.length][str1.length];
};

// Find best matching medicine name with fuzzy matching
const findBestMatch = (ocr_medicine, available_medicines, threshold = 2) => {
  const ocr_lower = ocr_medicine.toLowerCase().trim();
  
  // Exact match first
  const exact = available_medicines.find(
    m => m.medicine_name.toLowerCase() === ocr_lower
  );
  if (exact) return exact;

  // Fuzzy match
  let bestMatch = null;
  let bestDistance = threshold;

  available_medicines.forEach(medicine => {
    const distance = calculateLevenshteinDistance(
      ocr_lower,
      medicine.medicine_name.toLowerCase()
    );
    if (distance < bestDistance) {
      bestDistance = distance;
      bestMatch = medicine;
    }
  });

  return bestMatch;
};

// Parse dosage pattern (e.g., "1+0+1" -> 2)
const parseDosagePattern = (pattern) => {
  const cleaned = pattern.trim();
  const parts = cleaned.split("+").map(p => {
    const num = parseFloat(p.trim());
    return isNaN(num) ? 0 : num;
  });

  if (parts.length !== 3) {
    throw new Error(`Invalid dosage pattern: ${pattern}`);
  }

  return parts.reduce((sum, dose) => sum + dose, 0);
};

// Extract medicine entries from OCR text
const extractMedicinesFromOCR = (ocrText) => {
  const lines = ocrText.split("\n");
  const medicines = [];

  // Pattern to match medicine lines: "Type Medicine_name dosage_pattern"
  // Examples: "Tab Napa 1+0+1", "Cap Seclo 1+0+0", "Inj Abx 2+2+2"
  const medicinePattern =
    /^(tab|cap|inj|syrup|cream|oint|drops|spray|inhaler|patch|gel|powder|liquid|suspension|injection|capsule|tablet)\s+([a-zA-Z\s]+?)\s+(\d+\+\d+\+\d+)$/i;

  lines.forEach((line) => {
    const trimmed = line.trim();
    if (!trimmed) return; // Skip empty lines

    const match = trimmed.match(medicinePattern);
    if (match) {
      const [, type, medicine_name, dosage_pattern] = match;
      medicines.push({
        type: type.toLowerCase(),
        medicine_name: medicine_name.trim(),
        dosage_pattern: dosage_pattern.trim(),
      });
    }
  });

  return medicines;
};

// Analyze prescription for overdoses
exports.analyzePrescriptionOCR = (req, res) => {
  const { prescription_text } = req.body;

  // Validation
  if (!prescription_text || prescription_text.trim().length === 0) {
    return res.status(400).json({
      error: "Missing or empty prescription_text field",
    });
  }

  try {
    // Step 1: Extract medicines from OCR text
    const extracted_medicines = extractMedicinesFromOCR(prescription_text);

    if (extracted_medicines.length === 0) {
      return res.status(400).json({
        error: "No valid medicine entries found in the prescription text",
        example: "Expected format: Tab Napa 1+0+1",
      });
    }

    // Step 2: Query all medicines from database once
    const db_query = "SELECT medicine_name, max_daily_dose FROM medicines";
    db.query(db_query, (err, all_medicines) => {
      if (err) {
        return res.status(500).json({
          error: "Database error",
          details: err.message,
        });
      }

      // Step 3: Analyze each extracted medicine
      const analysis = [];
      const not_found = [];

      extracted_medicines.forEach((med) => {
        try {
          // Find matching medicine (with fuzzy matching)
          const db_medicine = findBestMatch(
            med.medicine_name,
            all_medicines,
            2
          );

          if (!db_medicine) {
            not_found.push(med.medicine_name);
            return;
          }

          // Parse dosage pattern
          const daily_dose = parseDosagePattern(med.dosage_pattern);
          const max_safe_dose = db_medicine.max_daily_dose;

          // Determine status
          const status = daily_dose <= max_safe_dose ? "SAFE" : "OVERDOSE";

          analysis.push({
            medicine: db_medicine.medicine_name,
            dose_pattern: med.dosage_pattern,
            daily_dose: daily_dose,
            max_safe_dose: max_safe_dose,
            status: status,
            type: med.type,
          });
        } catch (error) {
          not_found.push(`${med.medicine_name} (${error.message})`);
        }
      });

      // Step 4: Return results
      const response = {
        analysis: analysis,
        summary: {
          total_medicines: extracted_medicines.length,
          analyzed: analysis.length,
          safe_count: analysis.filter((a) => a.status === "SAFE").length,
          overdose_count: analysis.filter((a) => a.status === "OVERDOSE").length,
        },
      };

      if (not_found.length > 0) {
        response.not_found_or_invalid = not_found;
      }

      res.json(response);
    });
  } catch (error) {
    res.status(500).json({
      error: "Error processing prescription",
      details: error.message,
    });
  }
};

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
