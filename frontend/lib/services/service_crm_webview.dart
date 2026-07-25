import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// [CrmWebviewService] — Singleton manager for Windows WebView2 controller.
/// Configures explicit persistent userDataPath (%LOCALAPPDATA%\textile_erp\whatsapp_profile)
/// to prevent cold-sync cache re-downloads and keep load times under 1-2 seconds.
class CrmWebviewService {
  CrmWebviewService._();
  static final CrmWebviewService instance = CrmWebviewService._();

  WebviewController? _controller;
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isEnvInitialized = false;

  WebviewController get controller {
    _controller ??= WebviewController();
    return _controller!;
  }

  bool get isInitialized => _isInitialized && (_controller?.value.isInitialized ?? false);
  bool get isInitializing => _isInitializing;

  /// Resolves permanent disk profile path (%LOCALAPPDATA%\textile_erp\whatsapp_profile)
  String get _userDataPath {
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? r'C:\Users\Public';
    final profileDir = Directory('$localAppData\\textile_erp\\whatsapp_profile');
    if (!profileDir.existsSync()) {
      profileDir.createSync(recursive: true);
    }
    return profileDir.path;
  }

  Future<void> _ensureEnvironment() async {
    if (_isEnvInitialized) return;
    try {
      final path = _userDataPath;
      debugPrint('[CrmWebviewService] Initializing persistent WebView2 environment at: $path');
      await WebviewController.initializeEnvironment(
        userDataPath: path,
        additionalArguments:
            '--process-per-site '
            '--disable-background-networking '
            '--disable-breakpad '
            '--disable-component-update '
            '--disable-renderer-backgrounding '
            '--autoplay-policy=no-user-gesture-required '
            '--disable-features=Translate,MediaRouter,CalculateNativeWinOcclusion '
            '--enable-features=SharedArrayBuffer,UseSkiaRenderer '
            '--js-flags="--max-old-space-size=1024"',
      );
      _isEnvInitialized = true;
    } catch (e) {
      debugPrint('[CrmWebviewService] Environment initialization warning (or already initialized): $e');
      _isEnvInitialized = true;
    }
  }

  Future<void> ensureInitialized() async {
    // If already initialized and active, reuse existing process
    if (isInitialized) {
      debugPrint('[CrmWebviewService] Reusing existing WebView2 instance.');
      return;
    }

    if (_isInitializing) {
      debugPrint('[CrmWebviewService] Initialization already in progress...');
      return;
    }

    _isInitializing = true;
    try {
      // Step 1: Ensure persistent environment profile is configured
      await _ensureEnvironment();

      // Step 2: Defensively dispose stale controller if present
      if (_controller != null) {
        try {
          await _controller!.dispose();
        } catch (_) {}
        _controller = null;
      }

      _controller = WebviewController();
      await _controller!.initialize();
      await _controller!.loadUrl('https://web.whatsapp.com');
      _isInitialized = true;
      debugPrint('[CrmWebviewService] WebView2 instance initialized cleanly with persistent profile.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[CrmWebviewService] Initialization failed: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> reload() async {
    if (isInitialized) {
      await controller.reload();
    } else {
      await ensureInitialized();
    }
  }

  Future<void> loadUrl(String url) async {
    if (isInitialized) {
      await controller.loadUrl(url);
    } else {
      await ensureInitialized();
      await controller.loadUrl(url);
    }
  }

  Future<void> clearCacheAndReset() async {
    if (isInitialized) {
      await controller.clearCache();
      await controller.loadUrl('https://web.whatsapp.com');
    }
  }

  Future<void> forceDispose() async {
    if (_controller != null) {
      try {
        await _controller!.dispose();
        debugPrint('[CrmWebviewService] WebView2 instance force disposed.');
      } catch (e) {
        debugPrint('[CrmWebviewService] Force dispose error: $e');
      } finally {
        _controller = null;
        _isInitialized = false;
        _isInitializing = false;
      }
    }
  }

  /// Downloads open-source images to local disk (%TEMP%\textile_erp_staged_images) as native JPG files
  Future<List<File>> stageLocalSareeImageFiles(List<String> imageUrls, String designCode) async {
    final List<File> localFiles = [];
    try {
      final tempDir = Directory('${Directory.systemTemp.path}\\textile_erp_staged_images');
      if (!tempDir.existsSync()) {
        tempDir.createSync(recursive: true);
      }

      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);

      for (int i = 0; i < imageUrls.length; i++) {
        final url = imageUrls[i];
        final fileName = '${designCode.toLowerCase().replaceAll('-', '_')}_0${i + 1}.jpg';
        final file = File('${tempDir.path}\\$fileName');

        if (file.existsSync() && file.lengthSync() > 1000) {
          localFiles.add(file);
          continue;
        }

        try {
          final request = await httpClient.getUrl(Uri.parse(url));
          final response = await request.close().timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            final bytes = await consolidateHttpClientResponseBytes(response);
            if (bytes.isNotEmpty) {
              await file.writeAsBytes(bytes);
              localFiles.add(file);
            }
          }
        } catch (e) {
          debugPrint('[CrmWebviewService] Single image download error for $url: $e');
        }
      }
    } catch (e) {
      debugPrint('[CrmWebviewService] Error staging local files: $e');
    }
    return localFiles;
  }

  /// Copies native JPG binary image files to Windows OS Clipboard using super_clipboard
  Future<void> writeImageFilesToWindowsClipboard(List<File> imageFiles) async {
    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard != null && imageFiles.isNotEmpty) {
        final items = <DataWriterItem>[];
        for (final file in imageFiles) {
          if (file.existsSync()) {
            final bytes = await file.readAsBytes();
            final item = DataWriterItem();
            item.add(Formats.jpeg(bytes));
            item.add(Formats.fileUri(file.uri));
            items.add(item);
          }
        }
        if (items.isNotEmpty) {
          await clipboard.write(items);
          debugPrint('[CrmWebviewService] Staged ${items.length} JPEG items to SystemClipboard.');
        }
      }
    } catch (e) {
      debugPrint('[CrmWebviewService] SystemClipboard write error: $e');
    }
  }
}
