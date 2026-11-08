import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../workspace/document_session.dart';
import 'image_editor.dart';

class ImageViewer extends StatefulWidget {
  final DocumentSession session;

  const ImageViewer({super.key, required this.session});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radians = widget.session.imageRotationDegrees * (math.pi / 180.0);

    return Column(
      children: [
        // Image controls bar (Rotate, Flip)
        if (widget.session.isEditMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => widget.session.rotateImageClockwise(),
                  icon: const Icon(Icons.rotate_right, size: 18),
                  label: Text('${widget.session.imageRotationDegrees}°'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => widget.session.flipImageHorizontal(),
                  icon: const Icon(Icons.flip, size: 18),
                  label: const Text('पलटें'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final processed = await showDialog<Uint8List>(
                      context: context,
                      builder: (_) => ImageEditorDialog(session: widget.session),
                    );
                    if (processed != null) {
                      widget.session.updateImageBytes(processed);
                    }
                  },
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('रिसाइज़/कंप्रेस'),
                ),
              ],
            ),
          ),

        // Zoomable & Transformed Image
        Expanded(
          child: Container(
            color: Colors.black,
            child: ClipRect(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  widget.session.imageFlippedH ? -1.0 : 1.0,
                  widget.session.imageFlippedV ? -1.0 : 1.0,
                  1.0,
                )..rotateZ(radians),
                child: PhotoView(
                  imageProvider: MemoryImage(widget.session.activeImageBytes),
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 3.0,
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'इमेज लोड करने में असमर्थ',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
