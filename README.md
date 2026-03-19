PrescriptSense (Shashtho-Link)

AI-Based Digital Prescription Interpretation and Medication Safety System.

PrescriptSense is a mobile healthcare application designed to help users understand handwritten prescriptions and ensure medication safety. The system uses Optical Character Recognition (OCR) and Artificial Intelligence to extract and analyze prescription information.

The application provides features such as prescription interpretation, medicine identification, medication reminders, and emergency healthcare support.

Project Information

Course: CSE 4510 – Software Development Lab
Team: RuntimeError

Team Members

Rafat Abdullah — 220041102

Tasnia Rahman Maha — 220041114

Noshin Syara — 220041120

Sakline Muttakeen — 220041126

Md Fahim Tazoar Pramanik — 220041140

Asif Hasan — 220041156

Technologies Used
Mobile Application

Flutter

Dart

Artificial Intelligence

Python

OCR (Optical Character Recognition)

Database

SQLite

Tools

Git

GitHub

Android Studio / VS Code

Features
Prescription Interpretation

Upload or capture prescription images and extract:

Medicine name

Dosage

Frequency

Duration

Medicine Safety Checker

Detect potential issues such as:

Unsafe dosage

Drug–food interactions

AI Medical Assistant

Users can describe symptoms and receive AI-generated guidance.

Medicine Identification

Upload images of medicine tablets or packaging to identify them.

Medicine Reminder

Schedule reminders for medication intake.

Emergency Services

Locate nearby pharmacies and request ambulance support.

System Requirements
Hardware Requirements

Android smartphone or emulator

Camera support (for prescription scanning)

Software Requirements

Flutter SDK (latest version recommended)

Dart SDK

Android Studio or VS Code

Git

Python (for AI services if backend is run locally)

How to Clone the Project

Open terminal and run:

git clone https://github.com/tasniamaha/Prescript_Sense.git

Then move into the project directory:

cd Prescript_Sense
How to Run the Mobile Application
Step 1: Install Flutter Dependencies

Run:

flutter pub get

This installs all required packages.

Step 2: Connect a Device or Emulator

You can use:

Android phone (USB debugging enabled)

Android emulator from Android Studio

Check available devices:

flutter devices
Step 3: Run the Application

Execute:

flutter run

The app will build and launch on the connected device or emulator.

Running the Backend (If Required)

If the AI or OCR services run locally with Python:

Install Dependencies
pip install -r requirements.txt
Run the API server

Example:

python app.py

The mobile application will communicate with this backend service.

Project Structure (Simplified)
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
├── backend (Python OCR / AI services)
│
└── pubspec.yaml
Testing

Test cases include:

Authentication

AI assistant responses

OCR prescription scanning

Reminder scheduling

Emergency service features

A detailed bug report and testing document is available here:

Product Backlog and Bug Report
https://docs.google.com/spreadsheets/d/1Lj9ZeJecRXGGcw2o6xKejAPnIvgI3yy552YQOb0uaEI/edit

Known Issues

Some issues identified during testing include:

Hardcoded API key in source code

Plaintext password storage

Missing reminder notifications

Duplicate class definitions in certain modules

These issues are documented in the project evaluation report.

Future Improvements

Multi-user authentication system

Secure password hashing

Notification system for reminders

Real clinic search using Google Places API

Better AI prescription analysis

Ethical Notice

PrescriptSense provides supportive healthcare guidance only.
It does not replace professional medical advice from licensed healthcare providers.

Users should always consult qualified medical professionals before making medical decisions.
