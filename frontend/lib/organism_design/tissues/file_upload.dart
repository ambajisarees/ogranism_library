import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme.dart';

/// [TissueFileUpload] — Drag & Drop hitboxes for Media Zoning
/// Handled natively via desktop_drop and fallback to file_picker.
class TissueFileUpload extends StatefulWidget {
  final String label;
  final String subtitle;
  final void Function(List<PlatformFile> files)? onFilesSelected;
  final bool allowMultiple;
  final bool isUploading;

  const TissueFileUpload({
    super.key,
    required this.label,
    required this.subtitle,
    this.onFilesSelected,
    this.allowMultiple = true,
    this.isUploading = false,
  });

  @override
  State<TissueFileUpload> createState() => _TissueFileUploadState();
}

class _TissueFileUploadState extends State<TissueFileUpload> {
  bool _isDragging = false;

  Future<void> _pickFiles() async {
    // Yield thread to let current gesture arena & button hover states settle
    await Future.delayed(Duration.zero);
    final result = await FilePicker.pickFiles(
      allowMultiple: widget.allowMultiple,
      withData: true,
    );
    if (result != null && widget.onFilesSelected != null) {
      widget.onFilesSelected!(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = OrganismTheme.colorsOf(context);

    return DropTarget(
      onDragEntered: (detail) {
        setState(() => _isDragging = true);
      },
      onDragExited: (detail) {
        setState(() => _isDragging = false);
      },
      onDragDone: (detail) async {
        setState(() => _isDragging = false);
        if (widget.onFilesSelected != null) {
          final files = detail.files;
          final List<PlatformFile> parsed = [];
          for (var f in files) {
            final bytes = await f.readAsBytes();
            parsed.add(PlatformFile(
              name: f.name,
              size: bytes.length,
              bytes: bytes,
              path: f.path,
            ));
          }
          widget.onFilesSelected!(parsed);
        }
      },
      child: GestureDetector(
        onTap: widget.isUploading ? null : _pickFiles,
        child: AnimatedContainer(
          duration: OrganismTheme.durationFast,
          padding: const EdgeInsets.all(OrganismTheme.spacingXl),
          decoration: BoxDecoration(
            color: _isDragging ? colors.primary.withValues(alpha: 0.05) : colors.surface,
            border: Border.all(
              color: _isDragging ? colors.primary : colors.border,
              width: 2,
            ),
            borderRadius: OrganismTheme.borderLg,
          ),
          child: Center(
            child: widget.isUploading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.uploadCloud,
                        size: OrganismTheme.iconSizeXl,
                        color: _isDragging ? colors.primary : colors.textMuted,
                      ),
                      const SizedBox(height: OrganismTheme.spacingMd),
                      Text(
                        widget.label,
                        style: OrganismTheme.titleMedium(context).copyWith(
                          color: _isDragging ? colors.primary : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OrganismTheme.spacingXs),
                      Text(
                        widget.subtitle,
                        style: OrganismTheme.bodySmall(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
