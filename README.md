# Textile ERP System

This project contains the source code for a comprehensive ERP system designed for textile manufacturing.

## Structure

*   **/backend**: Python (FastAPI) + PostgreSQL backend.
    *   `schema.sql`: Contains the Database definition, including **Row Level Security** policies and **Staging Tables**.
    *   `app/sync_engine.py`: Logic for daily CSV synchronization.
*   **/frontend**: Flutter application (Desktop/Web/Mobile).
    *   `lib/main.dart`: Entry point with Sidebar navigation.

## Setup Instructions

### 1. Prerequisites
*   **Flutter SDK**: [Download and Install Flutter](https://docs.flutter.dev/get-started/install/windows)
*   **VS Code**: Recommended for editing. Install the "Flutter" and "Dart" extensions.

### 2. How to Run the App (Frontend)
Since the code is already generated in `frontend/lib`, follow these steps:

1.  **Open a Terminal** (PowerShell or Command Prompt).
2.  **Navigate to the frontend folder**:
    ```powershell
    cd C:\Users\smitt\.gemini\antigravity\scratch\textile_erp\frontend
    ```
3.  **Install Dependencies**:
    Downloads the necessary Flutter packages.
    ```powershell
    flutter pub get
    ```
4.  **Run the App**:
    *   To run as a **Windows Desktop App** (Recommended for ERP feel):
        ```powershell
        flutter run -d windows
        ```
    *   To run in **Chrome** (Web):
        ```powershell
        flutter run -d chrome
        ```
    *   To run on an **Android Emulator** (if set up):
        ```powershell
        flutter run
        ```

### 3. Backend Setup (PostgreSQL + Python)
*   **Install PostgreSQL**: [Download Here](https://www.postgresql.org/download/windows/).
*   **Create Database**:
    1.  Open `pgAdmin` or SQL Shell.
    2.  Run: `CREATE DATABASE textile_erp;`
    3.  Run the schema script:
        ```powershell
        psql -U postgres -d textile_erp -f "..\backend\schema.sql"
        ```
*   **Python Environment**:
    ```powershell
    cd ..\backend
    python -m venv venv
    .\venv\Scripts\Activate
    pip install fastapi uvicorn sqlalchemy psycopg2-binary pandas
    # Start Server (later)
    # uvicorn app.main:app --reload
    ```

### 4. Troubleshooting: "Command Not Found"
If you see errors like `'flutter' is not recognized` or `'git' is not recognized`:

**Quick Fix (Run this in your terminal to temporarily set the paths):**
```powershell
$env:Path = "C:\Program Files\Git\cmd;C:\Users\smitt\Downloads\flutter_windows_3.38.7-stable\flutter\bin;" + $env:Path
```

**Permanent Fix:**
1.  Search Windows for "Edit the system environment variables".
2.  Click "Environment Variables".
3.  In "User variables", find `Path` and click **Edit**.
4.  Add these two new lines:
    *   `C:\Program Files\Git\cmd`
    *   `C:\Users\smitt\Downloads\flutter_windows_3.38.7-stable\flutter\bin`
5.  **Restart VS Code** completely.

## Key Features Implemented (Draft)
*   **Permissions**: DB-enforced editing rules (Draft vs Locked).
*   **Sync**: `CSVSyncEngine` class ready to be connected to file watchers.
