# Beach Grain Sense

Beach Grain Sense is a cross-platform mobile app (Flutter) and backend (Python/FastAPI) for analyzing sand grain size using your phone's camera and geolocation. It uses computer vision to detect a ₹10 note as a scale reference, segments sand grains, and provides a detailed analysis including classification, average size, and distribution.

## Features
- Capture sand images with your phone camera
- Automatic detection of ₹10 note for scale
- Geolocation tagging
- Fast, on-device and server-side analysis
- Detailed results: average grain size, classification, distribution, and more

## Project Structure
- `lib/` — Flutter app source code
- `backend/` — Python FastAPI backend for image analysis
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` — Platform-specific code

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Python 3.8+
- pip (Python package manager)

### Setup: Flutter App
1. Navigate to the project root:
	```sh
	cd beach_grain_sense_flutter
	```
2. Get dependencies:
	```sh
	flutter pub get
	```
3. Run the app (choose your platform):
	```sh
	flutter run
	```

### Setup: Backend API
1. Navigate to the backend folder:
	```sh
	cd backend
	```
2. Install dependencies:
	```sh
	pip install -r requirements.txt
	```
3. Start the server:
	```sh
	uvicorn main:app --reload --host 0.0.0.0 --port 8000
	```

### Configuration
- Update the backend URL in `lib/services/api_service.dart` if running on a different machine or port.

## Usage
1. Launch the backend server.
2. Open the app on your device/emulator.
3. Place a ₹10 note next to the sand sample.
4. Use the app to capture an image and analyze.
5. View results including classification, average grain size, and distribution.

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
