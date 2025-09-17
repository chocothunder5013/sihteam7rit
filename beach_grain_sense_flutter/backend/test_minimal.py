
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional

app = FastAPI()

# Allow CORS for all origins (for development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI is working!"}

# Sample /analyze endpoint
@app.post("/analyze")
async def analyze(
    image: UploadFile = File(...),
    latitude: float = Form(...),
    longitude: float = Form(...)
):
    # For demonstration, just echo back the received data
    return {
        "result": "Sample analysis complete!",
        "filename": image.filename,
        "latitude": latitude,
        "longitude": longitude
    }
