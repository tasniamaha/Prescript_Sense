/**
 * Prescription Analysis - Unit Tests
 * 
 * Run tests with: node tests/test_ocr_analysis.js
 * Or with Jest: npm test
 */

const utils = require("../utils/prescriptionUtils");

let testCount = 0;
let passCount = 0;
let failCount = 0;

// Simple test assertion function
const assert = (condition, testName) => {
  testCount++;
  if (condition) {
    passCount++;
    console.log(`✓ ${testName}`);
  } else {
    failCount++;
    console.log(`✗ ${testName}`);
  }
};

const assertEqual = (actual, expected, testName) => {
  testCount++;
  if (actual === expected) {
    passCount++;
    console.log(`✓ ${testName}`);
  } else {
    failCount++;
    console.log(
      `✗ ${testName} - Expected: ${expected}, Got: ${actual}`
    );
  }
};

const assertDeepEqual = (actual, expected, testName) => {
  testCount++;
  try {
    assert(
      JSON.stringify(actual) === JSON.stringify(expected),
      testName
    );
  } catch (e) {
    failCount++;
    console.log(`✗ ${testName} - ${e.message}`);
  }
};

console.log("\n========== PRESCRIPTION UTILS TESTS ==========\n");

// Test parseDosageToObject
console.log("--- Dosage Pattern Parsing ---");
const dose1 = utils.parseDosageToObject("1+0+1");
assertEqual(dose1.morning, 1, "Parse: morning dose");
assertEqual(dose1.noon, 0, "Parse: noon dose");
assertEqual(dose1.night, 1, "Parse: night dose");
assertEqual(dose1.total, 2, "Parse: total daily dose");

const dose2 = utils.parseDosageToObject("2+2+1");
assertEqual(dose2.total, 5, "Parse: 2+2+1 = 5 total");

// Test formatDosagePattern
console.log("\n--- Format Dosage Pattern ---");
assertEqual(
  utils.formatDosagePattern(1, 0, 1),
  "1+0+1",
  "Format: 1+0+1"
);
assertEqual(
  utils.formatDosagePattern(2, 2, 1),
  "2+2+1",
  "Format: 2+2+1"
);

// Test getOverdoseStatus
console.log("\n--- Overdose Detection ---");
assertEqual(
  utils.getOverdoseStatus(2, 3),
  "SAFE",
  "Status: 2/3 = SAFE"
);
assertEqual(
  utils.getOverdoseStatus(3, 2),
  "OVERDOSE",
  "Status: 3/2 = OVERDOSE"
);
assertEqual(
  utils.getOverdoseStatus(3, 3),
  "SAFE",
  "Status: 3/3 = SAFE (equal)"
);

// Test getDosagePercentage
console.log("\n--- Dosage Percentage ---");
assertEqual(
  utils.getDosagePercentage(2, 4),
  "50.00",
  "Percentage: 2/4 = 50%"
);
assertEqual(
  utils.getDosagePercentage(3, 3),
  "100.00",
  "Percentage: 3/3 = 100%"
);
assertEqual(
  utils.getDosagePercentage(6, 4),
  "150.00",
  "Percentage: 6/4 = 150%"
);

// Test getWarningLevel
console.log("\n--- Warning Levels ---");
assertEqual(utils.getWarningLevel(50), "safe", "Level: 50% = safe");
assertEqual(utils.getWarningLevel(75), "safe", "Level: 75% = safe");
assertEqual(utils.getWarningLevel(80), "warning", "Level: 80% = warning");
assertEqual(utils.getWarningLevel(100), "warning", "Level: 100% = warning");
assertEqual(utils.getWarningLevel(150), "critical", "Level: 150% = critical");

// Test normalizeMedicineName
console.log("\n--- Medicine Name Normalization ---");
assertEqual(
  utils.normalizeMedicineName("  Napa  "),
  "napa",
  "Normalize: trim and lowercase"
);
assertEqual(
  utils.normalizeMedicineName("PARACETAMOL"),
  "paracetamol",
  "Normalize: UPPERCASE"
);
assertEqual(
  utils.normalizeMedicineName("Acy-clovir"),
  "acyclovir",
  "Normalize: remove special chars"
);

// Test isValidDosagePattern
console.log("\n--- Dosage Pattern Validation ---");
assert(utils.isValidDosagePattern("1+0+1"), "Valid: 1+0+1");
assert(utils.isValidDosagePattern("2+2+1"), "Valid: 2+2+1");
assert(utils.isValidDosagePattern("0+0+0"), "Valid: 0+0+0");
assert(!utils.isValidDosagePattern("1+0"), "Invalid: only 2 parts");
assert(!utils.isValidDosagePattern("1+0+1+1"), "Invalid: 4 parts");
assert(!utils.isValidDosagePattern("a+b+c"), "Invalid: non-numeric");
assert(!utils.isValidDosagePattern(""), "Invalid: empty string");
assert(!utils.isValidDosagePattern(null), "Invalid: null");

// Test extractMedicineType
console.log("\n--- Extract Medicine Type ---");
assertEqual(
  utils.extractMedicineType("Tab Napa"),
  "tab",
  "Extract: Tab"
);
assertEqual(
  utils.extractMedicineType("Cap Seclo"),
  "cap",
  "Extract: Cap"
);
assertEqual(
  utils.extractMedicineType("Inj Antibiotics"),
  "inj",
  "Extract: Inj"
);
assertEqual(
  utils.extractMedicineType("Syrup Cough"),
  "syrup",
  "Extract: Syrup"
);
assertEqual(
  utils.extractMedicineType("TABLET Aspirin"),
  "tablet",
  "Extract: Tablet (uppercase)"
);
assertEqual(
  utils.extractMedicineType("random text"),
  null,
  "Extract: Invalid type"
);

// Test validateMedicineEntry
console.log("\n--- Validate Medicine Entry ---");
const validMed = {
  medicine_name: "Napa",
  dosage_pattern: "1+0+1",
  max_daily_dose: 3
};
const result1 = utils.validateMedicineEntry(validMed);
assert(result1.valid, "Valid: complete medicine entry");

const invalidMed = {
  medicine_name: "",
  dosage_pattern: "invalid"
};
const result2 = utils.validateMedicineEntry(invalidMed);
assert(!result2.valid, "Invalid: empty name and bad pattern");
assert(
  result2.errors.length > 0,
  "Invalid: has error messages"
);

// Test formatMedicineAnalysis
console.log("\n--- Format Analysis Output ---");
const analysis = {
  medicine: "Napa",
  daily_dose: 2,
  max_safe_dose: 3,
  status: "SAFE"
};
const formatted = utils.formatMedicineAnalysis(analysis);
assert(formatted.includes("Napa"), "Format: contains medicine name");
assert(formatted.includes("2/3"), "Format: contains dosage ratio");
assert(formatted.includes("SAFE"), "Format: contains status");

// Test convertDosageUnit
console.log("\n--- Dosage Unit Conversion ---");
assertEqual(utils.convertDosageUnit(1, "g", "mg"), 1000, "Convert: 1g = 1000mg");
assertEqual(utils.convertDosageUnit(500, "mg", "g"), 0.5, "Convert: 500mg = 0.5g");
assertEqual(utils.convertDosageUnit(1, "l", "ml"), 1000, "Convert: 1l = 1000ml");
assertEqual(utils.convertDosageUnit(1000, "mcg", "mg"), 1, "Convert: 1000mcg = 1mg");

// Print summary
console.log("\n========== TEST SUMMARY ==========");
console.log(`Total Tests: ${testCount}`);
console.log(`✓ Passed: ${passCount}`);
console.log(`✗ Failed: ${failCount}`);
console.log(`Success Rate: ${((passCount / testCount) * 100).toFixed(2)}%`);

if (failCount > 0) {
  process.exit(1); // Exit with error if tests failed
} else {
  console.log("\n✓ All tests passed!");
  process.exit(0);
}
