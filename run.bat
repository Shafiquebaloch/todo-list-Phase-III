@echo off
REM Backend Startup Script
REM This script starts the FastAPI backend server with Neon database configuration

echo "🚀 Starting Task CRUD API Backend..."
echo "📊 Using Neon PostgreSQL Database"
echo.

REM Navigate to backend directory
cd "%~dp0backend" || exit /b 1

REM Load environment variables from .env file silently
for /f "tokens=*" %%a in (.env) do (
    echo %%a | findstr /r /c:"^[^#].*=" >nul && (
        for /f "tokens=1* delims==" %%b in ("%%a") do (
            set "%%b=%%c"
        )
    )
)

REM Create a temporary Python script for database connection test
echo import asyncio > temp_db_test.py
echo from src.database import engine >> temp_db_test.py
echo async def test_connection(): >> temp_db_test.py
echo     try: >> temp_db_test.py
echo         async with engine.connect() as conn: >> temp_db_test.py
echo             print("✅ Neon database connection successful!") >> temp_db_test.py
echo             return True >> temp_db_test.py
echo     except Exception as e: >> temp_db_test.py
echo         print(f"❌ Database connection failed: {e}") >> temp_db_test.py
echo         return False >> temp_db_test.py
echo result = asyncio.run(test_connection()) >> temp_db_test.py
echo exit(0 if result else 1) >> temp_db_test.py

echo "🔗 Testing Neon database connection..."
python temp_db_test.py
if %errorlevel% neq 0 (
    echo "❌ Could not connect to Neon database. Check your .env file."
    del temp_db_test.py
    exit /b 1
)
del temp_db_test.py

echo.
echo "✅ All checks passed!"
echo "🌐 Backend starting on http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo.
echo "Press Ctrl+C to stop the server"
echo.

REM Start the FastAPI server
python -m uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

pause