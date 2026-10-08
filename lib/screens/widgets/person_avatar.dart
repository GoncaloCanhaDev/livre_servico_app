import 'dart:io';

import 'package:flutter/material.dart';

import 'person_picker.dart';

/// A person's round photo, decoded at the size it is drawn rather than the
/// photo's full size, or their initials when there is no photo (or its file
/// is gone).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    required this.photoPath,
    this.size = 40,
  });

  final String name;
  final String? photoPath;

  /// The diameter.
  final double size;

  /// Whether each photo file exists, checked once per path instead of on
  /// every redraw.
  static final _exists = <String, bool>{};

  /// Forgets the decoded photos and file checks, after a photo is replaced
  /// (a person's new photo is saved under the same path).
  static void forget() {
    _exists.clear();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    if (path == null || !(_exists[path] ??= File(path).existsSync())) {
      return PersonInitialsBadge(name: name, size: size);
    }
    // Twice the size inside a square, so the shorter side of a photo up to
    // 2:1 still covers the circle sharply.
    final pixels = (2 * size * MediaQuery.devicePixelRatioOf(context)).round();
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: ResizeImage(
        FileImage(File(path)),
        width: pixels,
        height: pixels,
        policy: ResizeImagePolicy.fit,
      ),
    );
  }
}
