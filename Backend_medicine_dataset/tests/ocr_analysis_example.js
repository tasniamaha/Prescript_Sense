/**
 * OCR Prescription Analysis - Test Examples
 * 
 * This file demonstrates how to use the /api/medicine/analyze-prescription endpoint
 * for detecting overdoses from OCR-processed prescription text.
 */

// Example 1: Basic prescription text (matches your requirements)
const examplePrescription1 = `
Name: Rahim
Age: 45

Tab Napa 1+0+1
Cap Seclo 1+0+0
Tab Ace 1+1+1
`;

// Expected output:
// {
//   "analysis": [
//     {
//       "medicine": "Napa",
//       "dose_pattern": "1+0+1",
//       "daily_dose": 2,
//       "max_safe_dose": 3,
//       "status": "SAFE"
//     },
//     {
//       "medicine": "Seclo",
//       "dose_pattern": "1+0+0",
//       "daily_dose": 1,
//       "max_safe_dose": 1,
//       "status": "SAFE"
//     },
//     {
//       "medicine": "Ace",
//       "dose_pattern": "1+1+1",
//       "daily_dose": 3,
//       "max_safe_dose": 2,
//       "status": "OVERDOSE"
//     }
//   ],
//   "summary": {
//     "total_medicines": 3,
//     "analyzed": 3,
//     "safe_count": 2,
//     "overdose_count": 1
//   }
// }

// Example 2: Prescription with OCR spelling mistakes (fuzzy matching)
const examplePrescription2 = `
Patient: John Doe
Age: 35
Date: 2026-03-06

Tab Napa 2+2+1
Cap Secla 1+0+0
Tab Acp 2+2+1
`;

// The fuzzy matcher will correct "Secla" -> "Seclo" and "Acp" -> "Ace"
// if the distance is within threshold

// Example 3: Complex prescription with various medicine types
const examplePrescription3 = `
Patient Name: Maria Santos
Age: 52

Tab Aspirin 1+1+1
Cap Ibuprofen 0+1+1
Inj Antibiotics 1+1+0
Syrup Cough 5+0+5
Cream Dermal 0+0+0
`;

// Example 4: Edge case - prescription with invalid formats
const examplePrescription4 = `
Name: Test Patient

This is a comment line - should be ignored
Tab Napa 1+0+1
Some random text in between
Tab Ace 1+1+1
`;

// ============ CURL Examples ============

/*
// Example Request 1: Basic analysis
curl -X POST http://localhost:5000/api/medicine/analyze-prescription \
  -H "Content-Type: application/json" \
  -d '{
    "prescription_text": "Name: Rahim\nAge: 45\n\nTab Napa 1+0+1\nCap Seclo 1+0+0\nTab Ace 1+1+1"
  }'

// Example Request 2: With OCR errors (fuzzy matching)
curl -X POST http://localhost:5000/api/medicine/analyze-prescription \
  -H "Content-Type: application/json" \
  -d '{
    "prescription_text": "Tab Napa 2+2+1\nCap Secla 1+0+0\nTab Acp 2+2+1"
  }'

// Example Request 3: Multiple medicine types
curl -X POST http://localhost:5000/api/medicine/analyze-prescription \
  -H "Content-Type: application/json" \
  -d '{
    "prescription_text": "Tab Aspirin 1+1+1\nCap Ibuprofen 0+1+1\nInj Antibiotics 1+1+0\nSyrup Cough 5+0+5"
  }'
*/

// ============ JavaScript Fetch Examples ============

/*
// Example 1: Basic analysis with JavaScript fetch
const analyzePrescription = async (prescriptionText) => {
  try {
    const response = await fetch('http://localhost:5000/api/medicine/analyze-prescription', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        prescription_text: prescriptionText
      })
    });

    const result = await response.json();
    console.log('Analysis Result:', result);
    return result;
  } catch (error) {
    console.error('Error:', error);
  }
};

// Usage
analyzePrescription(examplePrescription1);

// Example 2: Handle response and check for overdoses
const checkForOverdoses = async (prescriptionText) => {
  const result = await analyzePrescription(prescriptionText);
  
  if (result.analysis) {
    const overdoses = result.analysis.filter(a => a.status === 'OVERDOSE');
    
    if (overdoses.length > 0) {
      console.warn(`⚠️ OVERDOSE DETECTED: ${overdoses.length} medicine(s)`);
      overdoses.forEach(med => {
        console.warn(
          `  - ${med.medicine}: ${med.daily_dose}/${med.max_safe_dose} units`
        );
      });
      return false; // Unsafe prescription
    } else {
      console.log('✓ All medicines are within safe limits');
      return true; // Safe prescription
    }
  }
};

// Usage
await checkForOverdoses(examplePrescription1);
*/

// ============ Database Setup ============

/*
CREATE TABLE medicines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  medicine_name VARCHAR(100) UNIQUE NOT NULL,
  max_daily_dose DECIMAL(5, 2) NOT NULL,
  unit VARCHAR(50),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO medicines (medicine_name, max_daily_dose, unit) VALUES
('Napa', 3, 'tablets'),
('Seclo', 1, 'capsule'),
('Ace', 2, 'tablets'),
('Aspirin', 2, 'tablets'),
('Ibuprofen', 3, 'capsules'),
('Antibiotics', 3, 'injections'),
('Cough', 10, 'ml');
*/

// ============ Response Format Documentation ============

/*
SUCCESS Response (200):
{
  "analysis": [
    {
      "medicine": "Napa",
      "dose_pattern": "1+0+1",
      "daily_dose": 2,
      "max_safe_dose": 3,
      "status": "SAFE",
      "type": "tab"
    }
  ],
  "summary": {
    "total_medicines": 3,
    "analyzed": 3,
    "safe_count": 2,
    "overdose_count": 1
  },
  "not_found_or_invalid": [] // Optional, if any medicines weren't found
}

ERROR Response (400/500):
{
  "error": "Error message",
  "details": "Detailed error information"
}

ANALYSIS.STATUS Values:
- "SAFE": daily_dose <= max_safe_dose ✓
- "OVERDOSE": daily_dose > max_safe_dose ⚠️

DOSAGE PATTERN:
- Format: "morning+noon+night"
- Example: "1+0+1" means 1 tablet morning, 0 noon, 1 night = 2 daily
- Each segment must be a number
- Total daily dose = sum of all three numbers
*/

module.exports = {
  examplePrescription1,
  examplePrescription2,
  examplePrescription3,
  examplePrescription4
};
