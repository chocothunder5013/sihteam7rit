
# Beach Grain Sense

Beach Grain Sense is a cross-platform, AI-powered application for analyzing beach sand grain samples using advanced image processing and geolocation. It empowers researchers, students, and enthusiasts to gain scientific insights into sand composition, grain size, and distribution, all from a mobile or desktop device.

---

## Table of Contents
1. Introduction
2. How It Works
3. Features
4. Project Structure
5. Prerequisites
6. Setup & Running
7. Usage
8. Customization & Development
9. Cleaning Up Redundant Files
10. Contributing
11. Support

---

## 1. Introduction
Beach Grain Sense is a cross-platform mobile app (Flutter) and backend (Python FastAPI) for analyzing sand grain size using your phone's camera and AI. It detects a currency note for scale and provides instant analysis.

---

## 2. How It Works

### User Journey
1. **Launch App:** User opens the app on any supported device.
2. **Home Screen:** Introduction, navigation to features.
3. **Capture/Select Image:** User takes a photo of sand grains or selects from gallery.
4. **Geolocation:** App fetches precise GPS coordinates.
5. **Submit for Analysis:** Image and location sent to backend.
6. **Processing:** Backend performs image segmentation, grain detection, and feature extraction.
7. **Results:** User receives detailed report (grain size, shape, distribution, location mapping).
8. **Save/Share:** Results can be saved locally or shared via email/social media.

### Data Flow
- **Input:** Image (JPEG/PNG), GPS coordinates.
- **Processing:** Image preprocessing, segmentation, feature extraction, statistical analysis.
- **Output:** JSON report with metrics, annotated image, location data.

---

## 3. Features
- Capture sand images with your phone camera
- Automatic detection of ₹10 note for scale
- Geolocation tagging
- Fast, on-device and server-side analysis
- Detailed results: average grain size, classification, distribution, and more

---

## 4. Project Structure
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

## 5. Prerequisites

- **For the app:**
    - Android Studio or VS Code with Flutter extension
    - Flutter SDK (see https://flutter.dev/docs/get-started/install)
- **For the backend:**
    - Python 3.10+
    - (Recommended) Create a virtual environment: `python -m venv .venv`

---

## 6. Setup & Running

### 6.1. Backend (Python)
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

### 6.2. Frontend (Flutter)
1. Open the project in Android Studio or VS Code.
2. Run `flutter pub get` to fetch dependencies.
3. Connect your Android device or start an emulator.
4. Run `flutter run` to launch the app.
5. To build an APK: `flutter build apk --release`
     - The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

### 6.3. Website
- Open `website/index.html` in your browser for app info and APK download.
- You can deploy this folder as a static site (e.g., GitHub Pages, Netlify).

---

## 7. Usage

1. Open the app and capture a photo of sand with a ₹10 note (or other supported scale) in the frame.
2. The app sends the image to the backend for analysis.
3. Results (grain size, classification, statistics) are shown instantly.
4. If analysis fails, you can retry without losing your photo.

---

## 8. Customization & Development

- **Frontend:** Modify UI in `lib/screens/` and API logic in `lib/services/api_service.dart`.
- **Backend:** Update analysis logic in `backend/main.py`. You can add deep learning models or new endpoints.
- **Testing:** Use `test/widget_test.dart` for Flutter widget tests. Backend can be tested with `test_minimal.py`.

---

## 9. Cleaning Up Redundant Files

- You can safely remove:
    - `backend/__pycache__/` and `backend/venv/` (if not using)
    - `.idea/`, `.dart_tool/`, `.metadata`, `.flutter-plugins-dependencies` (IDE and build artifacts)
    - Any unused build folders except for the APK
- Do NOT remove:
    - `lib/`, `backend/`, `website/`, `android/`, `ios/`, `pubspec.yaml`, `README.md`

---

## 10. Contributing

- Fork the repo, create a new branch, and submit a pull request for improvements.
- See `README.md` for more details.

---

## 11. Support

- For issues, open a GitHub issue or contact the maintainers.

---

Enjoy using Beach Grain Sense!

## API Reference

### `POST /analyze/`
**Description:** Analyze sand grain size from an image and GPS coordinates.

**Request (multipart/form-data):**
- `image_file`: Image file (JPEG/PNG)
- `gps_lat`: Latitude (float)
- `gps_lon`: Longitude (float)

**Response (JSON):**
- `gps_coordinates`: { latitude, longitude }
- `classification`: String (Wentworth scale)
- `average_grain_size_mm`: float
- `std_deviation_mm`: float
- `grain_count`: int
- `scale_pixels_per_mm`: float
- `scale_detection_confidence`: float (0-1)
- `segmentation_quality`: float (0-1)
- `size_distribution`: dict

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License.

---
For more details, see the code and comments in each module.

---

## Production Async Backend (Celery + Redis)

### Additional Prerequisites
- [Redis](https://redis.io/) (running locally or on a server)
- Celery (see `backend/requirements-celery.txt`)

### Setup: Backend Async Processing
1. Install extra dependencies:
    ```sh
    pip install -r requirements-celery.txt
    ```
2. Start Redis server (if not already running):
    ```sh
    redis-server
    ```
3. Start the FastAPI server (as before):
    ```sh
    uvicorn main:app --reload --host 0.0.0.0 --port 8000
    ```
4. Start the Celery worker (in a new terminal):
    ```sh
    celery -A main.celery_app worker --loglevel=info
    ```

### Async API Usage
- **Submit analysis job:**
    - `POST /analyze/` (same as before)
    - Response: `{ "job_id": "...", "status": "queued" }`
- **Poll for result:**
    - `GET /result/{job_id}`
    - Response:
        - `{ "status": "pending" }` (still processing)
        - `{ "status": "success", "result": { ... } }` (done)
        - `{ "status": "failure", "error": "..." }` (error)

### Example Client Flow
1. Submit image to `/analyze/` and get `job_id`.
2. Poll `/result/{job_id}` every few seconds until `status` is `success` or `failure`.
3. Display results to the user when ready.

---
