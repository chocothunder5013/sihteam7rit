# GUIDE.md

## Beach Grain Sense Project Guide

This guide will walk you through the structure, setup, and usage of the Beach Grain Sense project. It is written for users familiar with computers, but not necessarily with Flutter or Python development.

---

## 1. Project Overview

Beach Grain Sense is a cross-platform mobile app (Flutter) and backend (Python FastAPI) for analyzing sand grain size using your phone's camera and AI. It detects a currency note for scale and provides instant analysis.

---

## 2. Folder Structure

- `lib/` — Flutter app source code
  - `main.dart` — App entry point
  - `screens/` — UI screens (camera, home, results)
  - `services/` — API communication
  - `widgets/` — (for custom widgets, currently empty)
- `backend/` — Python FastAPI backend
  - `main.py` — Main backend server and analysis logic
  - `requirements.txt` — Python dependencies
  - `requirements-celery.txt` — Async task dependencies
- `website/` — Static website with APK download and info
- `build/app/outputs/flutter-apk/app-release.apk` — The Android APK
- `test/` — Flutter widget tests
- Platform folders: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`

---

## 3. Prerequisites

- **For the app:**
  - Android Studio or VS Code with Flutter extension
  - Flutter SDK (see https://flutter.dev/docs/get-started/install)
- **For the backend:**
  - Python 3.10+
  - (Recommended) Create a virtual environment: `python -m venv .venv`

---

## 4. Setup & Running

### 4.1. Backend (Python)
1. Open a terminal in the `backend/` folder.
2. Activate your virtual environment:
   - Windows: `.venv\Scripts\activate`
   - Mac/Linux: `source .venv/bin/activate`
3. Install dependencies:
   - `pip install -r requirements.txt`
   - For async tasks: `pip install -r requirements-celery.txt`
4. Start the backend server:
   - `python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000`
5. (Optional) Start Celery worker and Redis for async analysis.

### 4.2. Frontend (Flutter)
1. Open the project in Android Studio or VS Code.
2. Run `flutter pub get` to fetch dependencies.
3. Connect your Android device or start an emulator.
4. Run `flutter run` to launch the app.
5. To build an APK: `flutter build apk --release`
   - The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

### 4.3. Website
- Open `website/index.html` in your browser for app info and APK download.
- You can deploy this folder as a static site (e.g., GitHub Pages, Netlify).

---

## 5. Usage

1. Open the app and capture a photo of sand with a ₹10 note (or other supported scale) in the frame.
2. The app sends the image to the backend for analysis.
3. Results (grain size, classification, statistics) are shown instantly.
4. If analysis fails, you can retry without losing your photo.

---

## 6. Customization & Development

- **Frontend:** Modify UI in `lib/screens/` and API logic in `lib/services/api_service.dart`.
- **Backend:** Update analysis logic in `backend/main.py`. You can add deep learning models or new endpoints.
- **Testing:** Use `test/widget_test.dart` for Flutter widget tests. Backend can be tested with `test_minimal.py`.

---

## 7. Cleaning Up Redundant Files

- You can safely remove:
  - `backend/__pycache__/` and `backend/venv/` (if not using)
  - `.idea/`, `.dart_tool/`, `.metadata`, `.flutter-plugins-dependencies` (IDE and build artifacts)
  - Any unused build folders except for the APK
- Do NOT remove:
  - `lib/`, `backend/`, `website/`, `android/`, `ios/`, `pubspec.yaml`, `README.md`, `GUIDE.md`

---

## 8. Contributing

- Fork the repo, create a new branch, and submit a pull request for improvements.
- See `README.md` for more details.

---

## 9. Support

- For issues, open a GitHub issue or contact the maintainers.

---

Enjoy using Beach Grain Sense!
