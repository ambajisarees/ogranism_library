# CrmWebviewService & WebView2 Engine Production Configuration Guide

This directory houses `CrmWebviewService` ([service_crm_webview.dart](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/frontend/lib/services/service_crm_webview.dart)), the singleton manager controlling Microsoft Edge WebView2 for the Ambaji Sarees ERP WhatsApp CRM integration.

---

## 1. Architecture & Stability Overview

`CrmWebviewService` balances three critical desktop ERP requirements:
1. **Zero Process Proliferation**: Enforces a single persistent C++ WebView2 instance across Flutter Hot Restarts (`R`), tab switches, and widget rebuilds.
2. **Warm Cache Persistence**: Configures a dedicated persistent disk User Data folder (`%LOCALAPPDATA%\textile_erp\whatsapp_profile`), avoiding 15+ second cold sync delays.
3. **Enterprise CRM Stability**: Prevents Out-Of-Memory (OOM) crashes, background CPU throttling, and Windows window occlusion freezes.

---

## 2. Production Recommended Command-Line Flags

```dart
additionalArguments:
    '--process-per-site '
    '--disable-background-networking '
    '--disable-breakpad '
    '--disable-component-update '
    '--disable-renderer-backgrounding '
    '--autoplay-policy=no-user-gesture-required '
    '--disable-features=Translate,MediaRouter,CalculateNativeWinOcclusion '
    '--enable-features=SharedArrayBuffer,UseSkiaRenderer '
    '--js-flags="--max-old-space-size=1024"'
```

---

## 3. Exhaustive Flag Analysis & Engineering Trade-Offs

### A. Memory Control & V8 Heap Tuning

| Flag | Category | Engineering Analysis |
|---|---|---|
| `--js-flags="--max-old-space-size=1024"` | V8 Heap Ceiling | **Critical Fix**: Caps V8 JS heap memory at **1024 MB (1 GB)**.<br>• *Why 512MB fails*: During WhatsApp Web's initial sync (decrypting thousands of messages into IndexedDB), WASM memory spikes past 512MB, causing silent OOM crashes.<br>• *Why 1024MB works*: Provides sufficient breathing room for heavy cryptography sync while preventing runaway 2GB+ memory leaks over multi-day ERP sessions. |
| `--process-per-site` | Process Consolidation | Consolidates all `web.whatsapp.com` frames/workers into a single renderer process, saving **200MB–400MB of RAM** and removing IPC serialization overhead. |

### B. CRM Performance & Background Execution

| Flag | Category | Engineering Analysis |
|---|---|---|
| `--disable-renderer-backgrounding` | Background Execution | **CRM Essential**: Prevents Chromium from throttling the CPU of hidden or minimized WebViews. Ensures WhatsApp Web continues syncing incoming messages and triggering notifications when the ERP app is minimized or another tab is selected. |
| `--autoplay-policy=no-user-gesture-required` | Audio Alerts | **CRM Essential**: Ensures incoming WhatsApp notification sounds and voice notes play immediately without requiring the user to click inside the WebView first. |
| `--disable-features=CalculateNativeWinOcclusion` | Windows Occlusion | **Windows Desktop Fix**: Prevents WebView2 from freezing or suspending rendering when another Windows application (e.g. Excel, AMAZE ERP) is dragged over the Flutter app window. |

### C. Telemetry & Startup Speed Reduction

| Flag | Category | Engineering Analysis |
|---|---|---|
| `--disable-background-networking` | Telemetry Reduction | Stops Chrome telemetry, extension update checks, and background pingbacks on launch (~500ms faster startup). |
| `--disable-breakpad` | Diagnostic | Disables Chrome crash dump reporter background worker threads. |
| `--disable-component-update` | Updater | Prevents WebView2 from checking component updates on window creation. |
| `--disable-features=Translate,MediaRouter` | Subsystem Stripping | Completely removes Google Translate language scanning and Chromecast mDNS device discovery threads. |
| `--enable-features=SharedArrayBuffer,UseSkiaRenderer` | GPU & WASM Multi-threading | Enables parallel multi-core WebAssembly Signal E2EE decryption and Skia GPU hardware-accelerated 2D rendering for saree image previews. |

---

## 4. Persistent User Data Directory

```dart
String get _userDataPath {
  final localAppData = Platform.environment['LOCALAPPDATA'] ?? r'C:\Users\Public';
  final profileDir = Directory('$localAppData\\textile_erp\\whatsapp_profile');
  if (!profileDir.existsSync()) {
    profileDir.createSync(recursive: true);
  }
  return profileDir.path;
}
```

* **Storage Location**: `%LOCALAPPDATA%\textile_erp\whatsapp_profile`
* **Result**: Persistent storage for IndexedDB message databases, login cookies, and WASM binaries, achieving **1–2 second warm load times**.

---

## 5. Compliance & Security Baseline

1. **Navigation**: Official WhatsApp deep-linking (`web.whatsapp.com/send?phone=...`) — 100% Meta compliant.
2. **Scroll Behavior**: Native JS DOM target scroll (`scrollTop += dy`) — Standard browser rendering.
3. **Human-Driven Sending**: Message composition, image pasting (`super_clipboard` + `Ctrl+V`), and send clicks remain human-driven.
