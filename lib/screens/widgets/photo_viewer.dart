import 'dart:io';

import 'package:flutter/material.dart';

/// A row of small thumbnails for [paths]; tapping one opens it full screen.
/// With [onRemove], each thumbnail gets a ✕.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.paths, this.onRemove});

  final List<String> paths;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (i, path) in paths.indexed)
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PhotoViewerScreen(paths: paths, initialIndex: i),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(path),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    cacheWidth: 192,
                    errorBuilder: (_, _, _) => Container(
                      width: 64,
                      height: 64,
                      color: Colors.black12,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ),
              ),
              if (onRemove case final remove?)
                Positioned(
                  top: -8,
                  right: -8,
                  child: InkWell(
                    onTap: () => remove(path),
                    customBorder: const CircleBorder(),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// [paths] full screen, swipeable and zoomable, starting at [initialIndex].
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({
    super.key,
    required this.paths,
    this.initialIndex = 0,
  });

  final List<String> paths;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: PageView(
          controller: PageController(initialPage: initialIndex),
          children: [
            for (final path in paths)
              InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Image.file(
                    File(path),
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
