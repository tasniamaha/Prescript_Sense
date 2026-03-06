/**
 * Prescription Utilities
 * 
 * Reusable utility functions for prescription processing, dosage calculations,
 * and medicine data handling.
 */

/**
 * Parses a dosage pattern string (e.g., "1+0+1") into individual doses
 * @param {string} pattern - Dosage pattern like "morning+noon+night"
 * @returns {Object} Object with morning, noon, night doses and total
 */
const parseDosageToObject = (pattern) => {
  const parts = pattern.split("+").map(p => {
    const num = parseFloat(p.trim());
    return isNaN(num) ? 0 : num;
  });

  return {
    morning: parts[0] || 0,
    noon: parts[1] || 0,
    night: parts[2] || 0,
    total: (parts[0] || 0) + (parts[1] || 0) + (parts[2] || 0)
  };
};

/**
 * Formats dosage object back to pattern string
 * @param {number} morning
 * @param {number} noon
 * @param {number} night
 * @returns {string} Formatted pattern like "1+0+1"
 */
const formatDosagePattern = (morning, noon, night) => {
  return `${morning}+${noon}+${night}`;
};

/**
 * Determines overdose status
 * @param {number} daily_dose - Calculated daily dose
 * @param {number} max_safe_dose - Maximum safe dose from database
 * @returns {string} "SAFE" or "OVERDOSE"
 */
const getOverdoseStatus = (daily_dose, max_safe_dose) => {
  return daily_dose <= max_safe_dose ? "SAFE" : "OVERDOSE";
};

/**
 * Calculates percentage of safe dosage
 * Useful for UI visualization
 * @param {number} daily_dose
 * @param {number} max_safe_dose
 * @returns {number} Percentage (e.g., 66.67 for 2/3)
 */
const getDosagePercentage = (daily_dose, max_safe_dose) => {
  return (daily_dose / max_safe_dose * 100).toFixed(2);
};

/**
 * Generates warning level based on dosage percentage
 * @param {number} percentage
 * @returns {string} "safe" | "warning" | "critical"
 */
const getWarningLevel = (percentage) => {
  if (percentage <= 75) return "safe";
  if (percentage <= 100) return "warning";
  return "critical";
};

/**
 * Normalizes medicine name for comparison
 * Removes special characters and extra spaces
 * @param {string} name
 * @returns {string} Normalized name
 */
const normalizeMedicineName = (name) => {
  return name
    .toLowerCase()
    .trim()
    .replace(/\s+/g, " ")
    .replace(/[^a-z0-9\s]/g, "");
};

/**
 * Validates dosage pattern format
 * @param {string} pattern
 * @returns {boolean} True if valid
 */
const isValidDosagePattern = (pattern) => {
  if (!pattern || typeof pattern !== "string") return false;
  const parts = pattern.trim().split("+");
  if (parts.length !== 3) return false;
  return parts.every(p => {
    const num = parseFloat(p.trim());
    return !isNaN(num) && num >= 0;
  });
};

/**
 * Extracts medicine type from a medicine line
 * @param {string} line - Medicine line like "Tab Napa 1+0+1"
 * @returns {string|null} Medicine type or null if invalid
 */
const extractMedicineType = (line) => {
  const types = [
    "tab", "cap", "inj", "syrup", "cream", "oint",
    "drops", "spray", "inhaler", "patch", "gel",
    "powder", "liquid", "suspension", "injection",
    "capsule", "tablet"
  ];

  const lowerLine = line.toLowerCase();
  for (const type of types) {
    if (lowerLine.startsWith(type + " ")) {
      return type;
    }
  }
  return null;
};

/**
 * Validates a complete medicine entry
 * @param {Object} medicine - Medicine object with name, pattern, etc.
 * @returns {Object} Validation result {valid: boolean, errors: string[]}
 */
const validateMedicineEntry = (medicine) => {
  const errors = [];

  if (!medicine.medicine_name || medicine.medicine_name.trim().length === 0) {
    errors.push("Medicine name is required");
  }

  if (!isValidDosagePattern(medicine.dosage_pattern)) {
    errors.push(`Invalid dosage pattern: ${medicine.dosage_pattern}`);
  }

  if (medicine.max_daily_dose !== undefined && medicine.max_daily_dose <= 0) {
    errors.push("Max daily dose must be greater than 0");
  }

  return {
    valid: errors.length === 0,
    errors
  };
};

/**
 * Formats medicine analysis result for display
 * @param {Object} analysis - Single medicine analysis object
 * @returns {string} Formatted string for display
 */
const formatMedicineAnalysis = (analysis) => {
  const status_symbol = analysis.status === "SAFE" ? "✓" : "⚠️";
  const dosage_info = `${analysis.daily_dose}/${analysis.max_safe_dose}`;
  return `${status_symbol} ${analysis.medicine} ${dosage_info} units - ${analysis.status}`;
};

/**
 * Creates a summary report from analysis results
 * @param {Array} analysis - Analysis array
 * @returns {string} Formatted report
 */
const createAnalysisReport = (analysis) => {
  if (!analysis || analysis.length === 0) {
    return "No medicines to analyze.";
  }

  const safe = analysis.filter(a => a.status === "SAFE");
  const overdose = analysis.filter(a => a.status === "OVERDOSE");

  let report = `\nPrescription Analysis Report\n`;
  report += `${"=".repeat(40)}\n`;
  report += `Total Medicines: ${analysis.length}\n`;
  report += `Safe: ${safe.length}\n`;
  report += `Overdose Risk: ${overdose.length}\n`;
  report += `${"=".repeat(40)}\n`;

  if (overdose.length > 0) {
    report += `\n⚠️  OVERDOSE ALERTS:\n`;
    overdose.forEach(med => {
      report += `  - ${med.medicine}: ${med.daily_dose}/${med.max_safe_dose} units\n`;
    });
  }

  if (safe.length > 0) {
    report += `\n✓ Safe Medicines:\n`;
    safe.forEach(med => {
      report += `  - ${med.medicine}: ${med.daily_dose}/${med.max_safe_dose} units\n`;
    });
  }

  return report;
};

/**
 * Calculates drug interactions risk (placeholder for future implementation)
 * @param {Array} medicines - Array of medicine names
 * @returns {Object} Interaction warnings
 */
const checkDrugInteractions = (medicines) => {
  // TODO: Implement drug interaction database check
  // For now, returns empty interactions array
  return {
    interactions: [],
    severity: "none"
  };
};

/**
 * Converts dosage units between different formats
 * @param {number} dose - Amount of dose
 * @param {string} fromUnit - Original unit (e.g., "mg")
 * @param {string} toUnit - Target unit (e.g., "g")
 * @returns {number} Converted dose
 */
const convertDosageUnit = (dose, fromUnit, toUnit) => {
  // Common conversion factors
  const conversions = {
    "mg_to_g": 0.001,
    "g_to_mg": 1000,
    "ml_to_l": 0.001,
    "l_to_ml": 1000,
    "mcg_to_mg": 0.001,
    "mg_to_mcg": 1000,
  };

  const key = `${fromUnit.toLowerCase()}_to_${toUnit.toLowerCase()}`;
  const factor = conversions[key];

  if (factor === undefined) {
    throw new Error(`Cannot convert from ${fromUnit} to ${toUnit}`);
  }

  return dose * factor;
};

/**
 * Checks if a medicine requires specific timing or food intake
 * @param {string} medicine_name
 * @returns {Object} Timing requirements
 */
const getMedicineTiming = (medicine_name) => {
  // TODO: Implement timing database check
  return {
    with_food: null,
    spacing_hours: null,
    notes: null
  };
};

/**
 * Validates patient age eligibility for medicine
 * @param {string} medicine
 * @param {number} age
 * @returns {boolean} Whether medicine is appropriate for age
 */
const isAgeAppropriate = (medicine, age) => {
  // TODO: Implement age-based medicine restrictions
  return true; // Placeholder
};

module.exports = {
  parseDosageToObject,
  formatDosagePattern,
  getOverdoseStatus,
  getDosagePercentage,
  getWarningLevel,
  normalizeMedicineName,
  isValidDosagePattern,
  extractMedicineType,
  validateMedicineEntry,
  formatMedicineAnalysis,
  createAnalysisReport,
  checkDrugInteractions,
  convertDosageUnit,
  getMedicineTiming,
  isAgeAppropriate
};
