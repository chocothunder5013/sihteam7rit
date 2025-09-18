# Generalized scale detection for notes, cards, and coins
def find_scale_and_mask_reference(image: np.ndarray) -> Tuple[Optional[float], Optional[np.ndarray], float, Optional[str]]:
    """
    Finds a rectangular or circular scale reference (note, card, coin), calculates the
    pixels-per-mm ratio, and returns the ratio, a masked image, confidence level, and object type.

    Args:
        image: Input image containing the reference scale

    Returns:
        Tuple of (pixels_per_mm, masked_image, confidence_score, object_type)
        pixels_per_mm: Calculated scale factor
        masked_image: Image with the reference object masked out
        confidence_score: Confidence level (0-1) that the detected object is a valid reference
        object_type: String describing the detected reference object
    """
    # Reference database: (object_type, width_mm, height_mm, aspect_ratio, shape)
    reference_objects = [
        # Indian bank notes (width x height in mm)
        ("₹10 Note", 63.0, 123.0, 123.0/63.0, "rect"),
        ("₹20 Note", 63.0, 147.0, 147.0/63.0, "rect"),
        ("₹50 Note", 66.0, 135.0, 135.0/66.0, "rect"),
        ("₹100 Note", 66.0, 142.0, 142.0/66.0, "rect"),
        ("₹200 Note", 66.0, 146.0, 146.0/66.0, "rect"),
        ("₹500 Note", 66.0, 150.0, 150.0/66.0, "rect"),
        ("₹2000 Note", 66.0, 166.0, 166.0/66.0, "rect"),
        # Standard credit/debit card (ISO/IEC 7810 ID-1)
        ("Credit/Debit Card", 53.98, 85.60, 85.60/53.98, "rect"),
        # Indian coins (diameter in mm)
        ("₹1 Coin", 25.0, 25.0, 1.0, "circle"),
        ("₹2 Coin", 27.0, 27.0, 1.0, "circle"),
        ("₹5 Coin", 23.0, 23.0, 1.0, "circle"),
        ("₹10 Coin", 27.0, 27.0, 1.0, "circle"),
    ]

    img_copy = image.copy()
    gray = cv2.cvtColor(img_copy, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (7, 7), 0)
    edges = cv2.Canny(blurred, 50, 150)

    # Find contours
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if not contours:
        return None, None, 0.0, None

    # Sort contours by area in descending order
    contours = sorted(contours, key=cv2.contourArea, reverse=True)

    best_match = None
    best_confidence = 0.0
    best_pixels_per_mm = None
    best_object_type = None

    for c in contours:
        perimeter = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * perimeter, True)

        # Rectangle-like objects (notes, cards)
        if len(approx) == 4:
            rect = cv2.minAreaRect(approx)
            (_, _), (width_px, height_px), _ = rect
            if width_px > 0 and height_px > 0:
                contour_aspect = max(width_px, height_px) / min(width_px, height_px)
                for obj in reference_objects:
                    obj_type, obj_w, obj_h, obj_aspect, obj_shape = obj
                    if obj_shape != "rect":
                        continue
                    aspect_ratio_diff = abs(contour_aspect - obj_aspect)
                    # 20% tolerance
                    if aspect_ratio_diff <= 0.2 * obj_aspect:
                        confidence = 1.0 - (aspect_ratio_diff / obj_aspect)
                        # Use the shorter dimension for width
                        pixel_width = min(width_px, height_px)
                        pixels_per_mm = pixel_width / min(obj_w, obj_h)
                        if confidence > best_confidence:
                            best_match = approx
                            best_confidence = confidence
                            best_pixels_per_mm = pixels_per_mm
                            best_object_type = obj_type

        # Circle-like objects (coins)
        elif len(approx) > 6:
            (x, y), radius = cv2.minEnclosingCircle(approx)
            if radius > 5:  # Ignore very small circles
                diameter_px = 2 * radius
                for obj in reference_objects:
                    obj_type, obj_w, obj_h, obj_aspect, obj_shape = obj
                    if obj_shape != "circle":
                        continue
                    # Acceptable diameter tolerance: 15%
                    expected_diameter_mm = obj_w
                    confidence = 1.0  # Could refine with more checks
                    pixels_per_mm = diameter_px / expected_diameter_mm
                    if confidence > best_confidence:
                        best_match = approx
                        best_confidence = confidence
                        best_pixels_per_mm = pixels_per_mm
                        best_object_type = obj_type

    if best_match is None or best_pixels_per_mm is None:
        return None, None, 0.0, None

    # Mask the detected reference object
    if len(best_match) == 4:
        cv2.drawContours(img_copy, [best_match], -1, (0, 0, 0), -1)
    else:
        (x, y), radius = cv2.minEnclosingCircle(best_match)
        center = (int(x), int(y))
        cv2.circle(img_copy, center, int(radius), (0, 0, 0), -1)

    return best_pixels_per_mm, img_copy, best_confidence, best_object_type

import cv2
import numpy as np
import uvicorn
from fastapi import FastAPI, File, Form, UploadFile, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional, Dict, List, Tuple
import logging
import gc

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize the FastAPI app
app = FastAPI(title="Sand Grain Analysis API")

# Add CORS middleware after app is defined
# In production, set allow_origins to your frontend domain(s) only
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Change to ["https://your-frontend-domain.com"] for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize the FastAPI app
app = FastAPI(title="Sand Grain Analysis API")


@app.post("/analyze/")
async def analyze_sand(
    background_tasks: BackgroundTasks,
    image_file: UploadFile = File(...),
    gps_lat: Optional[float] = Form(None),
    gps_lon: Optional[float] = Form(None),
):
    """
    Receives an image and GPS coordinates, analyzes sand grain size, and returns results.
    Expects multipart/form-data with fields:
      - image_file: image/jpeg
      - gps_lat: float
      - gps_lon: float
    """
    # Phase 1: Data received and validation
    if not image_file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Uploaded file is not an image")


    try:
        contents = await image_file.read()
        nparr = np.frombuffer(contents, np.uint8)
        original_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if original_image is None:
            raise HTTPException(status_code=400, detail="Could not decode the image file")

        # Check if image is too small or empty
        if original_image.shape[0] < 100 or original_image.shape[1] < 100:
            raise HTTPException(status_code=400, detail="Image is too small for reliable analysis")
    except Exception as e:
        logger.error(f"Error processing image: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Image processing error: {str(e)}")

    # Resource cleanup after image decode
    del contents
    del nparr
    gc.collect()

    # Phase 2: Server-Side Processing

    def do_analysis():
        try:
            # Step 5 & 6: Pre-process and Detect Scale (generalized)
            pixels_per_mm, image_for_analysis, scale_confidence, scale_object_type = find_scale_and_mask_reference(original_image)
            if pixels_per_mm is None:
                raise HTTPException(status_code=400, detail="Could not detect a valid scale reference (note, card, or coin)")

            # Step 7, 8, 9: Segment and Measure
            diameters_mm, segmentation_quality = segment_and_measure_grains(image_for_analysis, pixels_per_mm)
            if not diameters_mm:
                raise HTTPException(status_code=400, detail="Could not segment or measure any grains")

            # Step 10: Analyze & Classify
            average_diameter_mm = np.mean(diameters_mm)
            std_deviation_mm = np.std(diameters_mm)
            classification = classify_wentworth(average_diameter_mm)
            grain_count = len(diameters_mm)

            # Calculate size distribution
            size_distribution = calculate_size_distribution(diameters_mm)

            # Final results payload
            results = {
                "gps_coordinates": {"latitude": gps_lat, "longitude": gps_lon},
                "classification": classification,
                "average_grain_size_mm": round(average_diameter_mm, 4),
                "std_deviation_mm": round(std_deviation_mm, 4),
                "grain_count": grain_count,
                "scale_pixels_per_mm": round(pixels_per_mm, 2),
                "scale_detection_confidence": scale_confidence,
                "scale_object_type": scale_object_type,
                "segmentation_quality": segmentation_quality,
                "size_distribution": size_distribution,
            }

            # Phase 3: Data Storage & Client Feedback
            # Step 11: Store Processed Data (Simple print statement for this example)
            # In a real app, you would save `results` to a database here.
            logger.info(f"Storing results: {results}")

            # Resource cleanup after analysis
            del image_for_analysis
            del original_image
            gc.collect()

            # Step 12 & 13: Send Results to Client
            return results
        except Exception as e:
            logger.error(f"Error in analysis pipeline: {str(e)}")
            raise HTTPException(status_code=500, detail=f"Analysis error: {str(e)}")

    # For now, run analysis in the request thread (safe, but can be offloaded)
    # To offload, use: background_tasks.add_task(do_analysis) and return a job id
    results = do_analysis()
    return results
# --- Batch Processing Extension Point ---
# To support batch uploads, add a new endpoint (e.g., /analyze_batch/) that accepts multiple images and processes them in a loop using the same efficient logic as above.




def segment_and_measure_grains(image: np.ndarray, pixels_per_mm: float) -> Tuple[List[float], float]:
    """
    Segments touching grains using the Watershed algorithm and measures them.

    Args:
        image: Input image with scale reference masked out
        pixels_per_mm: Scale factor for converting pixels to mm

    Returns:
        Tuple of (grain_diameters_mm, quality_score)
        grain_diameters_mm: List of grain diameters in mm
        quality_score: Measure of segmentation quality (0-1)
    """
    # --- Pre-processing for Segmentation ---
    # We use the image where the note has been masked out
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.medianBlur(gray, 5)  # Median blur is good for salt-and-pepper noise

    # Try different threshold parameters to find the best one
    best_thresh = None
    best_grain_count = 0

    # Test different block sizes for adaptive thresholding
    for block_size in [11, 21, 31]:
        if block_size >= min(gray.shape[0], gray.shape[1]):
            continue  # Skip if block size is too large for image

        thresh = cv2.adaptiveThreshold(
            blurred, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, block_size, 5
        )

        # Count rough number of potential grains
        num_labels, _ = cv2.connectedComponents(thresh)

        if num_labels > best_grain_count:
            best_grain_count = num_labels
            best_thresh = thresh

    # If adaptive thresholding failed, fall back to Otsu's method
    if best_thresh is None:
        _, best_thresh = cv2.threshold(blurred, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # --- "Predict Grain Centers" (Simulated with Distance Transform) ---
    # This finds the "sure foreground" which will act as markers
    dist_transform = cv2.distanceTransform(best_thresh, cv2.DIST_L2, 5)
    _, sure_fg = cv2.threshold(dist_transform, 0.5 * dist_transform.max(), 255, 0)
    sure_fg = np.uint8(sure_fg)

    # --- Apply Marker-Based Watershed Algorithm ---
    # Find unknown region
    unknown = cv2.subtract(cv2.dilate(best_thresh, np.ones((3, 3), np.uint8)), sure_fg)

    # Create the markers for the watershed algorithm
    _, markers = cv2.connectedComponents(sure_fg)
    # Add 1 to all labels so the background is 1, not 0
    markers = markers + 1
    # Mark the region of unknown with zero
    markers[unknown == 255] = 0

    # Apply watershed
    markers = cv2.watershed(image, markers)

    # --- Measure Individual Grains ---
    grain_diameters_mm = []
    total_grains = 0
    valid_grains = 0

    # Loop over the unique segments found by watershed
    # Label 1 is the background, so we ignore it
    for label in np.unique(markers):
        if label <= 1:
            continue

        total_grains += 1

        # Create a mask for the current grain
        mask = np.zeros(gray.shape, dtype="uint8")
        mask[markers == label] = 255

        # Calculate area in pixels
        area_pixels = cv2.countNonZero(mask)

        # Filter out very small objects (likely noise)
        min_area_pixels = 5  # Minimum area threshold
        if area_pixels <= min_area_pixels:
            continue

        valid_grains += 1

        # Calculate equivalent diameter (diameter of a circle with the same area)
        # Area = π * (d/2)^2  =>  d = sqrt(4 * Area / π)
        diameter_pixels = np.sqrt(4 * area_pixels / np.pi)

        # Convert diameter to mm
        diameter_mm = diameter_pixels / pixels_per_mm
        grain_diameters_mm.append(diameter_mm)

    # Quality score - combination of grain count and segmentation ratio
    quality_score = 0.0
    if total_grains > 0:
        quality_score = min(1.0, valid_grains / total_grains)

    return grain_diameters_mm, quality_score


def classify_wentworth(avg_diameter_mm: float) -> str:
    """
    Classifies sand based on the Wentworth scale.

    Args:
        avg_diameter_mm: Average grain diameter in mm

    Returns:
        Classification string according to the Wentworth scale
    """
    if avg_diameter_mm > 2.0:
        return "Gravel"
    elif avg_diameter_mm > 1.0:
        return "Very Coarse Sand"
    elif avg_diameter_mm > 0.5:
        return "Coarse Sand"
    elif avg_diameter_mm > 0.25:
        return "Medium Sand"
    elif avg_diameter_mm > 0.125:
        return "Fine Sand"
    elif avg_diameter_mm > 0.0625:
        return "Very Fine Sand"
    else:
        return "Silt/Clay"


def calculate_size_distribution(diameters_mm: List[float]) -> Dict[str, float]:
    """
    Calculates grain size distribution according to Wentworth scale.

    Args:
        diameters_mm: List of grain diameters in mm

    Returns:
        Dictionary with percentage of grains in each size category
    """
    if not diameters_mm:
        return {}

    categories = {
        "Gravel": 0,
        "Very Coarse Sand": 0,
        "Coarse Sand": 0,
        "Medium Sand": 0,
        "Fine Sand": 0,
        "Very Fine Sand": 0,
        "Silt/Clay": 0,
    }

    total_grains = len(diameters_mm)

    for diameter in diameters_mm:
        category = classify_wentworth(diameter)
        categories[category] += 1

    # Convert counts to percentages
    distribution = {category: (count / total_grains) * 100 for category, count in categories.items()}

    return distribution



"""
Sand Grain Analysis API (FastAPI)
---------------------------------
Receives sand images and GPS coordinates, detects a ₹10 note for scale, segments grains, and returns analysis results.

Endpoints:
    POST /analyze/
        - image_file: image (multipart/form-data)
        - gps_lat: float (optional)
        - gps_lon: float (optional)
        Returns: JSON with classification, average size, std deviation, grain count, scale info, and distribution.

Usage:
    1. Start server: uvicorn main:app --reload --host 0.0.0.0 --port 8000
    2. Send POST requests to /analyze/ with image and coordinates.

See README.md for full project documentation.
"""



