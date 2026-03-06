# Prescript Sense - Backend Medicine Dataset

## Overview

Backend system for Prescript Sense - A comprehensive prescription digitization and overdose detection platform. This backend handles prescription analysis, medicine safety verification, and patient data management.

## Project Structure

```
Backend_medicine_dataset/
├── controllers/
│   └── medicineController.js          # Main business logic
├── routes/
│   └── medicineRoutes.js              # API endpoints
├── utils/
│   └── prescriptionUtils.js           # Utility functions
├── tests/
│   ├── test_ocr_analysis.js           # Unit tests
│   └── ocr_analysis_example.js        # Example usage
├── docs/
│   ├── OCR_ANALYSIS.md                # Technical documentation
│   ├── INTEGRATION_EXAMPLES.md        # Framework examples
│   └── SETUP.md                       # Setup guide
├── db.js                              # Database configuration
├── server.js                          # Express server
├── package.json                       # Dependencies
└── .env                               # Environment variables
```

## Features

### ✅ Overdose Detection System
- **OCR Text Parsing** - Extracts medicines and dosages from prescription text
- **Fuzzy Matching** - Handles OCR spelling errors intelligently
- **Batch Analysis** - Analyzes multiple medicines in a single prescription
- **Database Integration** - Compares against safe dosage limits in MySQL
- **Comprehensive Reporting** - Detailed analysis with safe/overdose status

### ✅ Medicine Safety Verification
- Single medicine safety check via `/api/medicine/check`
- Full prescription analysis via `/api/medicine/analyze-prescription`
- Maximum safe dose comparison
- Unit conversions and dosage calculations

### ✅ Production-Ready
- Input validation and error handling
- Single database query optimization
- Comprehensive logging and debugging
- Unit tested (20+ tests, 100% pass rate)
- Full API documentation

## Quick Start

### Prerequisites
- Node.js 14+
- MySQL 5.7+
- npm

### Installation

1. **Install dependencies:**
```bash
npm install
```

2. **Configure environment variables:**
Create `.env` file with:
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=medicine_db
PORT=5000
```

3. **Create database:**
```sql
CREATE DATABASE medicine_db;
CREATE TABLE medicines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  medicine_name VARCHAR(100) UNIQUE NOT NULL,
  max_daily_dose DECIMAL(5, 2) NOT NULL,
  unit VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO medicines (medicine_name, max_daily_dose, unit) VALUES
('Napa', 3, 'tablets'),
('Seclo', 1, 'capsule'),
('Ace', 2, 'tablets');
```

4. **Start server:**
```bash
npm start
```

Server will run on `http://localhost:5000`

## API Endpoints

### 1. Analyze Full Prescription (NEW)

**POST `/api/medicine/analyze-prescription`**

Analyze OCR-processed prescription text for overdose risks.

**Request:**
```json
{
  "prescription_text": "Tab Napa 1+0+1\nCap Seclo 1+0+0\nTab Ace 1+1+1"
}
```

**Response:**
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

### 2. Single Medicine Check

**POST `/api/medicine/check`**

Check safety of a single medicine dose.

**Request:**
```json
{
  "medicine_name": "Napa",
  "dose": 2
}
```

**Response:**
```json
{
  "status": "SAFE",
  "message": "Prescribed dose is within safe limit"
}
```

## Dosage Format

Prescriptions use **Morning + Noon + Night** format:

```
Tab Napa 1+0+1          → 1 morning, 0 noon, 1 night = 2 daily
Cap Seclo 1+0+0         → 1 morning, 0 noon, 0 night = 1 daily
Tab Ace 1+1+1           → 1 morning, 1 noon, 1 night = 3 daily
```

## Supported Medicine Types

- Tab (Tablet)
- Cap (Capsule)
- Inj (Injection)
- Syrup
- Cream
- Oint (Ointment)
- Drops
- Spray
- Inhaler
- Patch
- Gel
- Powder
- Liquid
- Suspension

## Testing

**Run unit tests:**
```bash
node tests/test_ocr_analysis.js
```

**Test with cURL:**
```bash
curl -X POST http://localhost:5000/api/medicine/analyze-prescription \
  -H "Content-Type: application/json" \
  -d '{
    "prescription_text": "Tab Napa 1+0+1\nCap Seclo 1+0+0"
  }'
```

## Error Handling

| Code | Error | Solution |
|------|-------|----------|
| 400 | No valid medicine entries found | Check prescription format |
| 400 | Missing or empty prescription_text | Provide valid prescription text |
| 404 | Medicine not found | Verify medicine exists in database |
| 500 | Database error | Check database connection |

## Integration with Flutter

```dart
Future<void> analyzePrescription(String ocrText) async {
  final response = await http.post(
    Uri.parse('http://your-backend/api/medicine/analyze-prescription'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'prescription_text': ocrText}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    bool hasOverdose = data['analysis'].any((m) => m['status'] == 'OVERDOSE');
    // Handle overdose warning
  }
}
```

## Implementation Details

### Fuzzy Matching
The system uses Levenshtein distance algorithm to handle OCR spelling mistakes:
- **Exact match first** - Returns immediately if found
- **Fuzzy match** - Up to 2 character differences allowed
- **Examples**: "Secla"→"Seclo", "Acp"→"Ace", "Napaa"→"Napa"

### Dosage Parsing
- Validates format: `number + number + number`
- Automatically sums to daily dose
- Rejects invalid patterns

### Database Optimization
- Single query to fetch all medicines
- Fuzzy matching performed in-memory
- Minimal database load

## Documentation

| Document | Content |
|----------|---------|
| `docs/OCR_ANALYSIS.md` | Complete technical documentation (400+ lines) |
| `docs/INTEGRATION_EXAMPLES.md` | Code examples for Flutter, React, Python |
| `docs/SETUP.md` | Quick start and troubleshooting guide |

## Technologies

- **Runtime:** Node.js
- **Framework:** Express.js 5.x
- **Database:** MySQL 5.7+
- **Protocol:** REST API with JSON
- **Middleware:** CORS, body-parser

## Dependencies

```json
{
  "cors": "^2.8.6",
  "dotenv": "^17.2.3",
  "express": "^5.2.1",
  "mysql2": "^3.16.1"
}
```

## Future Enhancements

- [ ] Drug-drug interaction checking
- [ ] Patient allergy history integration
- [ ] Alternative dosage frequency patterns
- [ ] OCR confidence scoring
- [ ] PDF prescription support
- [ ] Multi-language support
- [ ] Audit logging and tracking
- [ ] Machine learning fuzzy matching

## Troubleshooting

**Package Issues:**
```bash
npm install --legacy-peer-deps
```

**Database Connection:**
```bash
mysql -h localhost -u root -p < setup.sql
```

**Port Already in Use:**
```bash
netstat -ano | findstr :5000
```

## Git Workflow

```bash
git checkout fahim_branch
git add <files>
git commit -m "feat: description"
git push origin fahim_branch
```

## Contributors

- **Fahim Tajoar** (@fahim-tajoar) - Backend Development
- User Email: fahimpramanik@iut-dhaka.edu

## License

Internal Use Only - Prescript Sense Project

## Support

For issues or documentation, refer to:
- `docs/` folder for detailed guides
- `tests/` folder for usage examples
- Code comments for implementation details

---

**Last Updated:** March 6, 2026  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
