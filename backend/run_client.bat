@echo off
REM filepath: c:\Users\ishan\OneDrive\Documents\sihihih\run_client.bat
echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing required packages...
pip install requests

echo Running test client...
python test_client

pause