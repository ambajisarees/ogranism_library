---
description: How to build and export the Flutter app for Windows desktop
---

# Flutter Windows Build & Export

## Prerequisites
- Flutter SDK installed and in PATH
- Visual Studio 2022 with C++ desktop workload
- Windows 10/11

## Steps

### 1. Run in Debug Mode (Development)
```powershell
cd frontend
flutter run -d windows
```

### 2. Run on Chrome (Web Debug)
```powershell
cd frontend
flutter run -d chrome
```

### 3. Build Windows Release
```powershell
cd frontend
flutter build windows --release
```
Output: `frontend/build/windows/x64/runner/Release/`

### 4. Generate MSIX Installer
```powershell
cd frontend
dart run msix:create
```
Output: MSIX file in `frontend/build/windows/x64/runner/Release/`

### 5. Install on Office PCs
1. Enable **Developer Mode** on target PC: Settings → For developers → Developer Mode ON
2. OR install the `.cer` certificate: Right-click → Install Certificate → Local Machine → Trusted Root Certification Authorities
3. Double-click the `.msix` file to install

## MSIX Config Location
`frontend/pubspec.yaml` → `msix_config` section

## Launcher Icons
- Config: `frontend/flutter_launcher_icons.yaml`
- Regenerate: `dart run flutter_launcher_icons`
- Source icon: Ambaji Sarees monogram PNG
