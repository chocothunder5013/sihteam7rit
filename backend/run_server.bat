@echo off
REM filepath: c:\Users\ishan\OneDrive\Documents\sihihih\run_server.bat
echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing required packages...
pip install -r requirements.txt

echo Starting the FastAPI server...
python -m uvicorn main:app --reload --host 127.0.0.1 --port 8000

pause