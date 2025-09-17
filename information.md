# Beach Grain Sense Flutter: Comprehensive User Manual & Technical Brochure

---

## Table of Contents
1. Introduction
2. Vision & Purpose
3. System Architecture
4. Detailed Workflow
5. User Guide
6. Technical Deep Dive
7. Backend (Python) - In-Depth
8. Frontend (Flutter) - In-Depth
9. Data Flow & Security
10. Platform Support & Deployment
11. Testing & Quality Assurance
12. Troubleshooting & FAQs
13. Contribution Guidelines
14. Glossary
15. Contact & Support

---

## 1. Introduction
Beach Grain Sense Flutter is a cross-platform, AI-powered application designed to analyze beach sand grain samples using advanced image processing and geolocation. It empowers researchers, students, and enthusiasts to gain scientific insights into sand composition, grain size, and distribution, all from a mobile or desktop device.

---

## 2. Vision & Purpose
- Democratize access to scientific sand analysis.
- Enable field researchers to collect, analyze, and share data instantly.
- Support environmental monitoring, academic research, and citizen science.

---

## 3. System Architecture
- **Frontend:** Flutter (Dart) for UI, cross-platform logic, device integration.
- **Backend:** Python (Flask/FastAPI) for image analysis, data processing, and API.
- **Communication:** RESTful HTTP API (JSON payloads, image uploads).
- **Data Storage:** Local (on device) and optionally cloud (future scope).

---

## 4. Detailed Workflow
### 4.1. User Journey
1. **Launch App:** User opens the app on any supported device.
2. **Home Screen:** Introduction, navigation to features.
3. **Capture/Select Image:** User takes a photo of sand grains or selects from gallery.
4. **Geolocation:** App fetches precise GPS coordinates.
5. **Submit for Analysis:** Image and location sent to backend.
6. **Processing:** Backend performs image segmentation, grain detection, and feature extraction.
7. **Results:** User receives detailed report (grain size, shape, distribution, location mapping).
8. **Save/Share:** Results can be saved locally or shared via email/social media.

### 4.2. Data Flow
- **Input:** Image (JPEG/PNG), GPS coordinates.
- **Processing:** Image preprocessing, segmentation, feature extraction, statistical analysis.
- **Output:** JSON report with metrics, annotated image, location data.

---

## 5. User Guide
### 5.1. Installation
- **Mobile:** Download from app store (future scope) or run via `flutter run`.
- **Desktop/Web:** Run via `flutter run -d windows` or `flutter run -d chrome`.
- **Backend:**
  - Navigate to `backend/`
  - Install dependencies: `pip install -r requirements.txt`
  - Start server: `python main.py` or `run_server.bat`

### 5.2. Using the App
- **Home Screen:** Overview, instructions, navigation.
- **Camera Screen:**
  - Tap to capture image.
  - Option to select from gallery.
- **Location Permission:**
  - Grant location access for accurate mapping.
- **Submit:**
  - Review image and location.
  - Tap 'Analyze' to send data.
- **Results Screen:**
  - View detailed analysis (grain size histogram, shape metrics, annotated image).
  - Save or share results.

### 5.3. Settings & Preferences
- Toggle location usage.
- Choose image resolution.
- Set default save location.

---

## 6. Technical Deep Dive
### 6.1. Image Processing Pipeline
- **Preprocessing:** Denoising, contrast enhancement.
- **Segmentation:** Thresholding, edge detection (OpenCV).
- **Feature Extraction:**
  - Grain size (area, diameter)
  - Shape (circularity, aspect ratio)
  - Count and distribution
- **Statistical Analysis:**
  - Mean, median, mode of grain sizes
  - Distribution plots

### 6.2. Geolocation Integration
- Uses Flutter geolocator plugin.
- Fetches latitude, longitude, and accuracy.
- Associates analysis with location for mapping.

### 6.3. API Communication
- **Endpoint:** `/analyze` (POST)
- **Payload:** Multipart (image + JSON metadata)
- **Response:** JSON with analysis results, error handling.

---

## 7. Backend (Python) - In-Depth
- **Framework:** Flask or FastAPI (modular, scalable)
- **Key Modules:**
  - `main.py`: API endpoints, request handling
  - `requirements.txt`: OpenCV, NumPy, Flask/FastAPI, Pillow
- **Image Analysis:**
  - Uses OpenCV for segmentation and feature extraction
  - NumPy for calculations
- **Error Handling:**
  - Validates input, returns clear error messages
- **Extensibility:**
  - Easy to add new analysis features (e.g., mineral detection)

---

## 8. Frontend (Flutter) - In-Depth
- **Project Structure:**
  - `lib/main.dart`: App entry point
  - `screens/`: UI screens (camera, home, results)
  - `services/api_service.dart`: Handles API calls
  - `widgets/`: Custom UI components
- **State Management:** Simple setState, can be extended to Provider/Bloc
- **Plugins Used:**
  - `geolocator`: Location
  - `image_picker`: Image selection
  - `http`: API requests
- **UI/UX:**
  - Responsive layouts
  - Clear navigation
  - Error and loading states

---

## 9. Data Flow & Security
- **Data Privacy:**
  - Images and location only sent with user consent
  - No persistent storage without permission
- **Security:**
  - Input validation on backend
  - Secure API endpoints (future: authentication)

---

## 10. Platform Support & Deployment
- **Supported Platforms:** Android, iOS, Web, Windows, macOS, Linux
- **Deployment:**
  - Backend: Local server, can be deployed to cloud (Heroku, AWS, etc.)
  - Frontend: Build for target platform using Flutter

---

## 11. Testing & Quality Assurance
- **Frontend:**
  - Widget and integration tests in `test/`
- **Backend:**
  - Unit tests in `backend/test_minimal.py`
- **Manual Testing:**
  - Cross-device, cross-platform

---

## 12. Troubleshooting & FAQs
- **App cannot connect to backend:** Ensure backend is running and accessible.
- **Location not detected:** Check device permissions.
- **Image upload fails:** Check file size and format.
- **Backend errors:** Review logs in `backend/`.

---

## 13. Contribution Guidelines
- Fork, branch, commit, and submit pull requests.
- Write clear commit messages.
- Add tests for new features.
- Follow code style guidelines.

---

## 14. Glossary
- **Grain Size:** Measurement of sand particle diameter.
- **Segmentation:** Separating grains from background in image.
- **Circularity:** How close a grain is to a perfect circle.
- **Aspect Ratio:** Ratio of width to height of a grain.

---

## 15. Contact & Support
- See `README.md` for maintainer contact.
- Open issues on GitHub for bugs/feature requests.

---

*This manual is intended to serve as a comprehensive guide for users, developers, and contributors. For further details, consult the source code and README.*
