# PrescriptSense (Shashtho-Link)

AI-Based Digital Prescription Interpretation and Medication Safety System.

PrescriptSense is a mobile healthcare application designed to help users understand handwritten prescriptions and ensure medication safety. The system uses Optical Character Recognition (OCR) and Artificial Intelligence to extract and analyze prescription information.

The application provides features such as prescription interpretation, medicine identification, medication reminders, and emergency healthcare support.

---

## 📌 Project Information

- **Course:** CSE 4510 – Software Development Lab  
- **Team:** RuntimeError  

---

## 👥 Team Members

- Rafat Abdullah — 220041102  
- Tasnia Rahman Maha — 220041114  
- Noshin Syara — 220041120  
- Sakline Muttakeen — 220041126  
- Md Fahim Tazoar Pramanik — 220041140  
- Asif Hasan — 220041156  

---

## 🛠️ Technologies Used

### 📱 Mobile Application
- Flutter  
- Dart  

### 🤖 Artificial Intelligence
- Python  
- OCR (Optical Character Recognition)  

### 💾 Database
- SQLite  

### 🔧 Tools
- Git  
- GitHub  
- Android Studio / VS Code  

---

## ✨ Features

### 🧾 Prescription Interpretation
Upload or capture prescription images and extract:
- Medicine name  
- Dosage  
- Frequency  
- Duration  

### ⚠️ Medicine Safety Checker
Detect potential issues such as:
- Unsafe dosage  
- Drug–food interactions  

### 🤖 AI Medical Assistant
Users can describe symptoms and receive AI-generated guidance.

### 💊 Medicine Identification
Upload images of medicine tablets or packaging to identify them.

### ⏰ Medicine Reminder
Schedule reminders for medication intake.

### 🚑 Emergency Services
- Locate nearby pharmacies  
- Request ambulance support  

---

## ⚙️ System Requirements

### 📱 Hardware Requirements
- Android smartphone or emulator  
- Camera support (for prescription scanning)  

### 💻 Software Requirements
- Flutter SDK (latest version recommended)  
- Dart SDK  
- Android Studio or VS Code  
- Git  
- Python (for AI services if backend is run locally)  

---

## 📥 How to Clone the Project

```bash
git clone https://github.com/tasniamaha/Prescript_Sense.git
cd Prescript_Sense
```

---

## ▶️ How to Run the Mobile Application

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Connect Device or Emulator
- Android phone (USB debugging enabled)  
- Android emulator  

Check available devices:
```bash
flutter devices
```

### Step 3: Run the App
```bash
flutter run
```

---

## 🧠 Running the Backend (If Required)

### Install Dependencies
```bash
pip install -r requirements.txt
```

### Run Server
```bash
python app.py
```

---

## 📁 Project Structure

```
Prescript_Sense
│
├── lib
│   ├── pages
│   ├── services
│   ├── widgets
│   └── main.dart
│
├── assets
│
├── android
├── ios
│
├── backend
│
└── pubspec.yaml
```

---

## 🧪 Testing

Test cases include:
- Authentication  
- AI assistant responses  
- OCR prescription scanning  
- Reminder scheduling  
- Emergency services  

📄 **Bug Report & Backlog:**  
https://docs.google.com/spreadsheets/d/1Lj9ZeJecRXGGcw2o6xKejAPnIvgI3yy552YQOb0uaEI/edit  

---

## ⚠️ Known Issues

- Hardcoded API key in source code  
- Plaintext password storage  
- Missing reminder notifications  
- Duplicate class definitions in some modules  

---

## 🚀 Future Improvements

- Multi-user authentication system  
- Secure password hashing  
- Notification system for reminders  
- Real clinic search using Google Places API  
- Improved AI prescription analysis  

---

## ⚖️ Ethical Notice

PrescriptSense provides supportive healthcare guidance only.  
It does not replace professional medical advice from licensed healthcare providers.

Users should always consult qualified medical professionals before making medical decisions.
