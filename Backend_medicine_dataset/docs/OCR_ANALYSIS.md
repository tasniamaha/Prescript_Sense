# OCR Prescription Analysis & Overdose Detection

## Overview

This module implements a complete overdose detection workflow for digitized prescriptions. It accepts raw OCR-processed prescription text, parses medicine entries, and compares prescribed doses against safe limits from a database.

## Features

✓ **OCR Text Parsing** - Extracts medicine names and dosage patterns from raw OCR text  
✓ **Flexible Format Support** - Recognizes multiple medicine types (Tab, Cap, Inj, Syrup, Cream, etc.)  
✓ **Fuzzy Matching** - Handles OCR spelling mistakes using Levenshtein distance algorithm  
✓ **Batch Analysis** - Analyzes multiple medicines in a single prescription  
✓ **Comprehensive Output** - Returns detailed analysis with status, summaries, and error reporting  
✓ **Production-Ready** - Error handling, input validation, database optimization  

## API Endpoint

### POST `/api/medicine/analyze-prescription`

Analyzes a prescription for overdose risks.

**Request Body:**
```json
{
  "prescription_text": "Name: Patient Name\nAge: 45\n\nTab Napa 1+0+1\nCap Seclo 1+0+0\nTab Ace 1+1+1"
}
```

**Success Response (200):**
```json
{
  "analysis": [
    {
      "medicine": "Napa",
      "dose_pattern": "1+0+1",
      "daily_dose": 2,
      "max_safe_dose": 3,
      "status": "SAFE",
      "type": "tab"
    },
    {
      "medicine": "Ace",
      "dose_pattern": "1+1+1",
      "daily_dose": 3,
      "max_safe_dose": 2,
      "status": "OVERDOSE",
      "type": "tab"
    }
  ],
  "summary": {
    "total_medicines": 3,
    "analyzed": 3,
    "safe_count": 2,
    "overdose_count": 1
  }
}
```

**Error Response (400/500):**
```json
{
  "error": "Missing or empty prescription_text field",
  "details": "Error details if available"
}
```

## Input Format

### Prescription Text Format
```
Name: Patient Name (ignored)
Age: 45 (ignored)
Any other header info (ignored)

Tab Napa 1+0+1
Cap Seclo 1+0+0
Tab Ace 1+1+1
Inj Antibiotic 2+2+1
Syrup Cough 5+0+5
```

### Supported Medicine Types
- **Tab** - Tablet
- **Cap** - Capsule
- **Inj** - Injection
- **Syrup** - Syrup
- **Cream** - Cream
- **Oint** - Ointment
- **Drops** - Drops
- **Spray** - Spray
- **Inhaler** - Inhaler
- Plus any other medicine type format

### Dosage Pattern
- **Format**: `morning + noon + night`
- **Example**: `1+0+1` = 1 in morning, 0 noon, 1 night = **2 daily**
- Each segment must be a number (0-9+)
- Daily dose = sum of all three numbers

## Implementation Details

### Core Functions

#### 1. `extractMedicinesFromOCR(ocrText)`
Parses prescription text and extracts medicine entries.

```javascript
Input:  "Tab Napa 1+0+1\nCap Seclo 1+0+0"
Output: [
  { type: 'tab', medicine_name: 'Napa', dosage_pattern: '1+0+1' },
  { type: 'cap', medicine_name: 'Seclo', dosage_pattern: '1+0+0' }
]
```

**Regex Pattern:**
```
^(tab|cap|inj|...)\s+([a-zA-Z\s]+?)\s+(\d+\+\d+\+\d+)$
```

#### 2. `parseDosagePattern(pattern)`
Converts dosage pattern string to total daily dose.

```javascript
Input:  "1+0+1"
Output: 2

Input:  "2+2+1"
Output: 5
```

#### 3. `findBestMatch(ocr_medicine, available_medicines, threshold)`
Fuzzy matches OCR medicine names against database names.

- **Exact match first** - Returns immediately if found
- **Fuzzy match** - Uses Levenshtein distance if exact match fails
- **Threshold** - Default=2 (allows 2 character differences)

```javascript
// Examples of fuzzy matching:
"Secla" → "Seclo" (1 character difference)
"Acp" → "Ace" (1 character difference)
"Napaa" → "Napa" (1 character difference)
```

#### 4. `analyzePrescriptionOCR(req, res)`
Main controller function that orchestrates the workflow:

1. Validates input
2. Extracts medicines from OCR text
3. Queries database once for all medicines
4. Analyzes each medicine for overdose risk
5. Returns comprehensive analysis

### Database Optimization
- Single database query for all medicines (efficient for prescriptions with multiple entries)
- Fuzzy matching done in-memory after database retrieval

### Error Handling
- Invalid prescription text format
- Empty medicine patterns
- Non-numeric dosage values
- Missing medicines in database
- Database connection errors

## Database Schema

Required table structure:

```sql
CREATE TABLE medicines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  medicine_name VARCHAR(100) UNIQUE NOT NULL,
  max_daily_dose DECIMAL(5, 2) NOT NULL,
  unit VARCHAR(50),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Sample data:
```sql
INSERT INTO medicines (medicine_name, max_daily_dose, unit) VALUES
('Napa', 3, 'tablets'),
('Seclo', 1, 'capsule'),
('Ace', 2, 'tablets'),
('Aspirin', 2, 'tablets'),
('Ibuprofen', 3, 'capsules'),
('Antibiotics', 3, 'injections');
```

## Usage Examples

### JavaScript Fetch (Flutter/Web Integration)

```javascript
// Simple analysis
const response = await fetch('http://localhost:5000/api/medicine/analyze-prescription', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    prescription_text: "Tab Napa 1+0+1\nCap Seclo 1+0+0"
  })
});

const result = await response.json();

// Check for overdoses
const hasOverdose = result.analysis.some(med => med.status === 'OVERDOSE');
if (hasOverdose) {
  console.warn('⚠️ Prescription contains overdose risk');
}
```

### cURL

```bash
curl -X POST http://localhost:5000/api/medicine/analyze-prescription \
  -H "Content-Type: application/json" \
  -d '{
    "prescription_text": "Tab Napa 1+0+1\nCap Seclo 1+0+0\nTab Ace 1+1+1"
  }'
```

### Python Requests

```python
import requests
import json

data = {
    "prescription_text": "Tab Napa 1+0+1\nCap Seclo 1+0+0\nTab Ace 1+1+1"
}

response = requests.post(
    'http://localhost:5000/api/medicine/analyze-prescription',
    json=data
)

result = response.json()
for med in result['analysis']:
    print(f"{med['medicine']}: {med['status']}")
```

## Fuzzy Matching Details

### Levenshtein Distance Algorithm

The implementation calculates the minimum number of single-character edits (insertions, deletions, substitutions) needed to transform one string into another.

**Threshold: 2 (default)**
- Allows up to 2 character differences
- Suitable for OCR errors (single character mistakes or small typos)

**Examples:**
```
"Napa" ↔ "Napaa"    : 1 edit (insert) - MATCH ✓
"Seclo" ↔ "Secla"   : 1 edit (substitute) - MATCH ✓
"Ace" ↔ "Acp"       : 1 edit (substitute) - MATCH ✓
"Napa" ↔ "Panadol"  : 4+ edits - NO MATCH ✗
```

### Adjusting Fuzzy Matching

To change the threshold, modify the `findBestMatch` call in `analyzePrescriptionOCR`:

```javascript
// More lenient (allows 3 character differences)
const db_medicine = findBestMatch(med.medicine_name, all_medicines, 3);

// Stricter (allows only 1 character difference)
const db_medicine = findBestMatch(med.medicine_name, all_medicines, 1);
```

## Response Status Codes

| Code | Meaning |
|------|---------|
| **200** | Success - Analysis complete |
| **400** | Bad Request - Invalid input or no medicines found |
| **500** | Server Error - Database or parsing error |

## Output Fields

### Medicine Analysis Object

```json
{
  "medicine": "Napa",                    // Medicine name from database
  "dose_pattern": "1+0+1",               // Original pattern from OCR
  "daily_dose": 2,                       // Calculated total daily dose
  "max_safe_dose": 3,                    // From database
  "status": "SAFE",                      // "SAFE" or "OVERDOSE"
  "type": "tab"                          // Medicine type
}
```

### Summary Object

```json
{
  "total_medicines": 3,                  // Total entries in prescription
  "analyzed": 3,                         // Successfully analyzed
  "safe_count": 2,                       // Medicines within safe limits
  "overdose_count": 1                    // Medicines exceeding safe limits
}
```

## Limitations & Future Improvements

### Current Limitations
- Single dosage pattern format (Morning+Noon+Night only)
- Prescription text must follow specific format
- No support for variable dosages or frequency changes
- No drug-drug interaction checking
- No allergy history integration

### Future Enhancements
1. **Alternative dose patterns** - Support "twice daily", "every 6 hours", etc.
2. **Drug interactions** - Check for harmful medicine combinations
3. **Patient history** - Consider allergy and previous reactions
4. **Dosage validation** - Check minimum effective dose as well
5. **OCR confidence scoring** - Track OCR accuracy and flag low-confidence entries
6. **Audit logging** - Track all prescriptions analyzed
7. **PDF prescription support** - Accept scanned PDFs directly
8. **Machine learning** - Improve fuzzy matching with ML models
9. **Multi-language support** - Handle prescriptions in multiple languages

## Integration with Flutter Frontend

### Example Flutter Widget Integration

This module can be called from Flutter using the `http` package:

```dart
Future<void> analyzePrescription(String ocrText) async {
  final response = await http.post(
    Uri.parse('http://your-backend/api/medicine/analyze-prescription'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'prescription_text': ocrText
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    // Check for overdoses
    bool hasOverdose = data['analysis']
        .any((med) => med['status'] == 'OVERDOSE');
    
    if (hasOverdose) {
      showAlert('⚠️ Overdose Risk Detected');
    }
  }
}
```

## Testing

See `tests/ocr_analysis_example.js` for:
- Example prescription texts
- cURL request examples
- JavaScript fetch examples
- Expected outputs
- Edge case examples

## Files Modified/Created

- **Modified**: `controllers/medicineController.js` - Added new controller function
- **Modified**: `routes/medicineRoutes.js` - Added new route endpoint
- **Created**: `tests/ocr_analysis_example.js` - Test cases and examples
- **Created**: `docs/OCR_ANALYSIS.md` - This documentation

## Environment Variables Required

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=medicine_db
PORT=5000
```

## Support & Troubleshooting

### Issue: "No valid medicine entries found"
**Solution**: Check prescription text format against regex pattern:
```
[MedicineType] [MedicineName] [Dosage]
Example: Tab Napa 1+0+1
```

### Issue: Medicine not found despite being in database
**Solution**: 
1. Check spelling in database
2. Adjust fuzzy matching threshold
3. Ensure database query is working (test with `/api/medicine/check`)

### Issue: Incorrect dosage calculation
**Solution**: Verify dosage pattern:
- Must be exactly 3 numbers separated by `+`
- Examples: `1+0+1`, `2+2+1`, `0+1+0`
- Invalid: `1+0`, `1+0+1+1`, `1 0 1`

---

**Implementation Date**: March 6, 2026  
**Version**: 1.0  
**Status**: Production Ready
