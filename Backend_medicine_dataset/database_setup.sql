-- Prescript Sense Medicine Database Setup Script
-- Date: March 6, 2026
-- Author: Fahim Tajoar
-- Description: SQL schema and initial data for medicine overdose detection system

-- ============================================================
-- CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS medicine_db;
USE medicine_db;

-- ============================================================
-- DROP EXISTING TABLES (OPTIONAL - for fresh setup)
-- ============================================================
-- DROP TABLE IF EXISTS medicines;
-- DROP TABLE IF EXISTS prescriptions;
-- DROP TABLE IF EXISTS audit_logs;

-- ============================================================
-- CREATE MEDICINES TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS medicines (
  id INT PRIMARY KEY AUTO_INCREMENT,
  medicine_name VARCHAR(100) UNIQUE NOT NULL,
  max_daily_dose DECIMAL(5, 2) NOT NULL,
  unit VARCHAR(50) DEFAULT 'tablets',
  description TEXT,
  category VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_medicine_name (medicine_name),
  INDEX idx_category (category)
);

-- ============================================================
-- CREATE PRESCRIPTIONS TABLE (Optional - for audit trail)
-- ============================================================

CREATE TABLE IF NOT EXISTS prescriptions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  patient_id VARCHAR(100),
  patient_name VARCHAR(100),
  prescription_text LONGTEXT,
  analysis_result LONGTEXT,
  has_overdose BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_patient_id (patient_id),
  INDEX idx_has_overdose (has_overdose)
);

-- ============================================================
-- CREATE AUDIT LOGS TABLE (Optional - for tracking)
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  action VARCHAR(50),
  medicine_name VARCHAR(100),
  daily_dose DECIMAL(5, 2),
  max_safe_dose DECIMAL(5, 2),
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_medicine_name (medicine_name)
);

-- ============================================================
-- INSERT INITIAL MEDICINE DATA
-- ============================================================

INSERT INTO medicines (medicine_name, max_daily_dose, unit, category, description) VALUES

-- Common Pain Relief Medicines
('Napa', 3, 'tablets', 'Pain Relief', 'Paracetamol - Common pain reliever and fever reducer'),
('Aspirin', 2, 'tablets', 'Pain Relief', 'Acetylsalicylic acid - Pain reliever and anti-inflammatory'),
('Ibuprofen', 3, 'capsules', 'Pain Relief', 'Common pain reliever and anti-inflammatory'),

-- Gastrointestinal Medicines
('Seclo', 1, 'capsule', 'Gastro', 'Pantoprazole - Reduces stomach acid'),
('Omeprazole', 1, 'capsule', 'Gastro', 'Proton pump inhibitor for acid reflux'),
('Ranitidine', 2, 'tablets', 'Gastro', 'H2 blocker for heartburn'),

-- Cardiovascular Medicines
('Ace', 2, 'tablets', 'Cardiovascular', 'ACE inhibitor for blood pressure'),
('Amlodipine', 1, 'tablet', 'Cardiovascular', 'Calcium channel blocker for hypertension'),
('Atorvastatin', 1, 'tablet', 'Cardiovascular', 'Statin for cholesterol management'),

-- Antibiotics
('Amoxicillin', 3, 'capsules', 'Antibiotic', 'Beta-lactam antibiotic'),
('Azithromycin', 1, 'tablet', 'Antibiotic', 'Macrolide antibiotic - Z-pack'),
('Ciprofloxacin', 2, 'tablets', 'Antibiotic', 'Fluoroquinolone antibiotic'),

-- Antidiabetic Medicines
('Metformin', 3, 'tablets', 'Antidiabetic', 'First-line treatment for type 2 diabetes'),
('Insulin', 3, 'units', 'Antidiabetic', 'Insulin therapy for diabetes'),
('Glibenclamide', 2, 'tablets', 'Antidiabetic', 'Sulfonylurea for diabetes'),

-- Antihypertensive Medicines
('Lisinopril', 2, 'tablets', 'Antihypertensive', 'ACE inhibitor for high blood pressure'),
('Losartan', 1, 'tablet', 'Antihypertensive', 'ARB for blood pressure control'),
('Atenolol', 1, 'tablet', 'Antihypertensive', 'Beta-blocker for hypertension'),

-- Cough & Cold
('Cough Syrup', 10, 'ml', 'Respiratory', 'Dextromethorphan cough suppressant'),
('Cetirizine', 1, 'tablet', 'Respiratory', 'Antihistamine for allergies'),
('Salbutamol', 2, 'inhalations', 'Respiratory', 'Bronchodilator for asthma'),

-- Anti-inflammatory
('Naproxen', 2, 'tablets', 'Anti-inflammatory', 'NSAID for pain and inflammation'),
('Diclofenac', 2, 'tablets', 'Anti-inflammatory', 'NSAID for pain relief'),
('Meloxicam', 1, 'tablet', 'Anti-inflammatory', 'NSAID for arthritis'),

-- Antibacterial/Antiseptic
('Antibiotic Cream', 3, 'grams', 'Topical', 'Antibiotic ointment for wounds'),
('Povidone Iodine', 2, 'applications', 'Topical', 'Antiseptic solution'),
('Chlorhexidine', 2, 'applications', 'Topical', 'Antiseptic solution');

-- ============================================================
-- VERIFY DATA
-- ============================================================

SELECT COUNT(*) as total_medicines FROM medicines;
SELECT medicine_name, max_daily_dose, unit, category FROM medicines ORDER BY category, medicine_name;

-- ============================================================
-- SAMPLE QUERIES FOR TESTING
-- ============================================================

-- Find medicine by name
-- SELECT * FROM medicines WHERE medicine_name LIKE 'Napa%';

-- Get all medicines in a category
-- SELECT * FROM medicines WHERE category = 'Pain Relief';

-- Find medicines with high daily dose limit
-- SELECT * FROM medicines WHERE max_daily_dose >= 2 ORDER BY max_daily_dose DESC;

-- ============================================================
-- OPTIONAL: Reset & Cleanup
-- ============================================================

-- To reset all data:
-- TRUNCATE TABLE medicines;
-- INSERT INTO medicines (...) VALUES (...);

-- To drop database (WARNING - deletes everything):
-- DROP DATABASE medicine_db;

-- ============================================================
-- NOTES
-- ============================================================
/*
1. medicine_name must be UNIQUE
2. max_daily_dose is in DECIMAL(5,2) format - handles up to 999.99
3. Indexes on medicine_name and category for performance
4. Created_at and Updated_at timestamps are automatic
5. For production, add backup and replication policies

Common Dosage Formats:
- Tablets/Capsules: count per day (e.g., 3 tablets)
- Injections: amount per day (e.g., 2 units)
- Liquids/Syrups: ml per day (e.g., 10 ml)
- Topical: grams or applications (e.g., 3 grams)
- Inhalations: number per day (e.g., 2 puffs)

*/
