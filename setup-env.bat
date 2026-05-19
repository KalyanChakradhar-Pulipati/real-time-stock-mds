@echo off
REM Real-Time Stock MDS - Setup Script for Windows

echo ========================================
echo Real-Time Stock MDS - Setup Script
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    exit /b 1
)

echo [OK] Python found
echo.

REM Create .env from .env.example
if not exist .env (
    echo [*] Creating .env from .env.example
    copy .env.example .env
    echo [OK] .env created
    echo [!] Please edit .env with your credentials:
    echo     notepad .env
) else (
    echo [OK] .env already exists
)

echo.

REM Setup pre-commit hook
echo [*] Setting up pre-commit hook
if not exist .git\hooks mkdir .git\hooks
if exist .githooks\pre-commit (
    copy .githooks\pre-commit .git\hooks\pre-commit
    echo [OK] Pre-commit hook installed
) else (
    echo [!] .githooks\pre-commit not found
)

echo.

REM Create virtual environment
if not exist venv (
    echo [*] Creating virtual environment
    python -m venv venv
    echo [OK] Virtual environment created
) else (
    echo [OK] Virtual environment already exists
)

echo.

REM Activate virtual environment
echo [*] Activating virtual environment
call venv\Scripts\activate.bat

echo.

REM Install dependencies
echo [*] Installing dependencies
pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt >nul 2>&1
echo [OK] Dependencies installed

echo.

REM Verify environment variables
echo [*] Testing environment variable loading
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print('[OK] Env vars loaded successfully')" 2>nul || echo [!] Could not verify env vars

echo.

echo ========================================
echo [OK] Setup Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Edit .env with your credentials:
echo    notepad .env
echo.
echo 2. Add your environment variables:
echo    - SNOWFLAKE_USER
echo    - SNOWFLAKE_PASSWORD
echo    - SNOWFLAKE_ACCOUNT
echo    - FINNHUB_API_KEY
echo.
echo 3. Start Docker services:
echo    docker-compose up -d
echo.
echo 4. Run the producer:
echo    python producer/producer.py
echo.
echo 5. In another terminal, run the consumer:
echo    python consumer/consumer.py
echo.
echo 6. Monitor Airflow at: http://localhost:8080
echo.
echo For more info, read: SETUP.md
echo.
pause
