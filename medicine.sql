-- Table for storing medicine data
CREATE TABLE medicines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255),
    dosage_form VARCHAR(255),
    strength VARCHAR(255),
    manufacturer VARCHAR(255),
    unit_price DECIMAL(10,2),
    strip_price DECIMAL(10,2),
    indications TEXT,
    pharmacology TEXT,
    dosage_administration TEXT,
    contraindications TEXT,
    side_effects TEXT,
    precautions_warnings TEXT,
    therapeutic_class VARCHAR(255),
    storage_conditions TEXT
);

-- Sample data insertion
INSERT INTO medicines 
(name, generic_name, dosage_form, strength, manufacturer, unit_price, strip_price, indications, pharmacology, dosage_administration, contraindications, side_effects, precautions_warnings, therapeutic_class, storage_conditions)
VALUES
('Napa Tablet', 'Paracetamol', 'Tablet', NULL, 'Beximco Pharmaceuticals Ltd.', 1.20, 12.00,
'Used as antipyretic (fever reducer) and analgesic (pain reliever)',
'Paracetamol works by inhibiting prostaglandin synthesis, reducing fever and pain.',
'Adult: 1-2 tablets every 4-6 hours up to 4g daily. Children: 1/2 to 1 tablet 3-4 times daily. See full dosage for syrup, suppository, IV infusion.',
NULL,
NULL,
NULL,
'Analgesic, Antipyretic',
'Store below 30°C, away from light and moisture.');

INSERT INTO medicines 
(name, generic_name, dosage_form, strength, manufacturer, unit_price, strip_price, indications, pharmacology, dosage_administration, contraindications, side_effects, precautions_warnings, therapeutic_class, storage_conditions)
VALUES
('Ace Tablet', 'Paracetamol', 'Tablet', NULL, 'Square Pharmaceuticals PLC', 1.20, 12.00,
'Used as antipyretic and analgesic',
'Paracetamol reduces pain and fever by inhibiting prostaglandins.',
'Adult: 1-2 tablets every 4-6 hours up to 4g daily. Children: 1/2 to 1 tablet 3-4 times daily. See full dosage for syrup, suppository, IV infusion.',
NULL,
NULL,
NULL,
'Analgesic, Antipyretic',
'Store below 30°C, away from light and moisture.');

INSERT INTO medicines 
(name, generic_name, dosage_form, strength, manufacturer, unit_price, strip_price, indications, pharmacology, dosage_administration, contraindications, side_effects, precautions_warnings, therapeutic_class, storage_conditions)
VALUES
('Brexpa Tablet', 'Brexpiprazole', 'Tablet', '1 mg', 'Renata PLC', 15.00, 150.00,
'Adjunctive treatment of major depressive disorder and schizophrenia',
'Acts as partial agonist at 5-HT1A and D2 receptors and antagonist at 5-HT2A receptors.',
'Start with 0.5-1 mg once daily for depression, titrate to 2 mg. For schizophrenia start 1 mg, titrate to 2-4 mg daily.',
'Hypersensitivity to brexpiprazole',
'Extrapyramidal symptoms, akathisia, suicidality, QT prolongation, weight gain, nausea',
'Caution in elderly, hepatic/renal impairment, pregnancy, metabolic changes, compulsive behaviors',
'Benzodiazepine antagonist',
'Do not store above 30°C, keep away from light and moisture.');

INSERT INTO medicines 
(name, generic_name, dosage_form, strength, manufacturer, unit_price, strip_price, indications, pharmacology, dosage_administration, contraindications, side_effects, precautions_warnings, therapeutic_class, storage_conditions)
VALUES
('Mirakof Syrup', 'Butamirate Citrate', 'Syrup', '7.5 mg/5 ml', 'Square Pharmaceuticals PLC', 80.24, NULL,
'Relieves dry (non-productive) cough',
'Acts on brain cough center to suppress cough, non-sedating',
'Adults: 15 ml 4 times daily. Children: 5-15 ml depending on age. See full dosage for tablet/drops.',
'Hypersensitivity to active ingredient',
'Rash, nausea, diarrhoea, vertigo',
'Avoid concomitant use with expectorants, caution in pregnancy and breastfeeding',
'Cough suppressant',
'Store below 30°C, keep away from light and moisture.');

INSERT INTO medicines 
(name, generic_name, dosage_form, strength, manufacturer, unit_price, strip_price, indications, pharmacology, dosage_administration, contraindications, side_effects, precautions_warnings, therapeutic_class, storage_conditions)
VALUES
('Askorel SR Tablet', 'Butamirate Citrate', 'SR Tablet', '50 mg', 'Incepta Pharmaceuticals Ltd.', 10.00, 100.00,
'Relieves dry (non-productive) cough',
'Acts on brain cough center to suppress cough, non-sedating',
'Adults: 2-3 tablets daily. Children: 0.5-15 ml syrup depending on age. See full dosage for pediatric drops.',
'Hypersensitivity to active ingredient',
'Rash, nausea, diarrhoea, vertigo',
'Avoid concomitant use with expectorants, caution in pregnancy and breastfeeding',
'Cough suppressant',
'Store below 30°C, keep away from light and moisture.');

INSERT INTO medicines 
(name, generic_name, dosage_form, strength, manufacturer, unit_price, strip_price, indications, pharmacology, dosage_administration, contraindications, side_effects, precautions_warnings, therapeutic_class, storage_conditions)
VALUES
('G-Omeprazole Capsule', 'Omeprazole', 'Capsule (Enteric Coated)', '20 mg', 'Gonoshasthaya Pharma Ltd.', 3.45, 34.50,
'Treatment of gastric and duodenal ulcers, GERD, acid-related dyspepsia, Zollinger-Ellison syndrome, H. pylori eradication',
'Inhibits gastric acid secretion by blocking H+/K+ ATPase in parietal cells',
'Oral: 10-60 mg daily depending on condition. IV: 40-60 mg for prophylaxis or treatment. See full instructions for IV infusion.',
'Hypersensitivity to Omeprazole',
'Mild rash, urticaria, pruritus, constipation, nausea/vomiting, headache',
'Avoid concomitant use with clopidogrel, caution in pregnancy, osteoporosis risk, methotrexate toxicity',
'Proton Pump Inhibitor',
'Store in dry place, away from light and heat.');
