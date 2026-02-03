PrescriptSense 🧠💊

A Flutter-powered intelligent prescription assistant

📌 Overview

PrescriptSense is a modern Flutter application designed to transform handwritten medical prescriptions into clear, safe, and intelligent digital insights. The app focuses on usability, accessibility, and patient safety by combining clean UI, animations, and AI-ready architecture.

The landing page features a glassmorphism UI, smooth animations, and a scalable structure suitable for healthcare-focused applications.

✨ Key Features

🧾 Intelligent Prescription Scanning
OCR-ready design for handwritten prescriptions

🔊 Audio Guidance
Voice-based medication instructions

⏰ Smart Reminders
Timely alerts to avoid missed doses

🛡️ Drug Safety Analysis
Detects interactions and contraindications

🎨 Glassmorphism UI
Backdrop blur, gradients, and modern visuals

⚡ Smooth Animations
Fade + slide hero animations using AnimationController

🛠️ Tech Stack

Framework: Flutter

Language: Dart

UI: Material Design + Custom Glassmorphism

Animations: Flutter Animation API

Navigation: Navigator 1.0

Architecture: Scalable widget-based design

📂 Project Structure
lib/
├── main.dart
├── landing_page.dart
├── dashboard_page.dart
├── SIgnup_Login.dart
assets/
├── image/
│   └── Prescript_Sense.png
├── pattern.png

📦 Dependencies

All dependencies are from Flutter SDK.

Required import for blur effects:

import 'dart:ui';


No third-party packages are required for the landing page UI.

▶️ How to Run

Clone the repository

git clone https://github.com/your-username/prescriptsense.git
cd prescriptsense


Get dependencies

flutter pub get


Run the app

flutter run

🖼️ Assets Setup

Ensure pubspec.yaml includes:

flutter:
  assets:
    - assets/image/Prescript_Sense.png
    - assets/pattern.png

🧪 Tested On

Android Emulator (API 30+)

Flutter stable channel

Material 3 compatible

🚀 Future Enhancements

AI-powered OCR integration

Drug database & interaction engine

Wearable device integration

Cloud sync & user profiles

Multilingual support

Offline-first architecture

👩‍💻 Author

PrescriptSense Team
Built with Flutter to make healthcare safer and smarter.

📄 License

This project is for educational and research purposes.
License can be added as needed
