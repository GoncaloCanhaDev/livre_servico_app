import 'package:flutter/material.dart';

import '../../services/photo_store.dart';
import 'person_picker.dart';

/// A person's round photo, decoded at the size it is drawn rather than the
/// photo's full size, or their initials while it loads and when there is no
/// photo (or it can't be had: see [PhotoStore.load]).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    required this.photoPath,
    this.size = 40,
  });

  final String name;

  /// A [PhotoStore] reference.
  final String? photoPath;

  /// The diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = PersonInitialsBadge(name: name, size: size);
    final ref = photoPath;
    if (!PhotoStore.isRef(ref)) return initials;
    // Twice the size inside a square, so the shorter side of a photo up to
    // 2:1 still covers the circle sharply.
    final pixels = (2 * size * MediaQuery.devicePixelRatioOf(context)).round();
    return ClipOval(
      child: Image(
        image: ResizeImage(
          PhotoImage(ref!),
          width: pixels,
          height: pixels,
          policy: ResizeImagePolicy.fit,
        ),
        width: size,
        height: size,
        fit: BoxFit.cover,
        frameBuilder: (_, child, frame, sync) =>
            frame == null && !sync ? initials : child,
        errorBuilder: (_, _, _) => initials,
      ),
    );
  }
}
