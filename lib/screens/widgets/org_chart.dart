import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/person.dart';
import 'person_picker.dart';

class PersonNode {
  PersonNode(this.person, this.children);
  final Person person;
  final List<PersonNode> children;
}

/// Builds the forest of [PersonNode]s from a manager-uuid grouping (see
/// `PersonService.groupByManager`). A person with several managers gets a
/// full card+subtree rendered once under each of them — this is a
/// deliberate "replicate the node" rendering for dual-reporting, not a
/// bug. The cycle guard tracks visited uuids per root-to-node path (not
/// globally) so a legitimate dual-report isn't mistaken for a repeat
/// visit; the app itself should never create an actual cycle (see
/// `PersonService.subtreeUuids`), but a corrupted/edited-outside-the-app
/// row still shouldn't be able to hang the UI.
List<PersonNode> buildForest(Map<String?, List<Person>> byManager) {
  PersonNode build(Person p, Set<String> pathVisited) {
    if (!pathVisited.add(p.syncUuid)) return PersonNode(p, const []);
    final kids = byManager[p.syncUuid] ?? const <Person>[];
    return PersonNode(
      p,
      kids.map((k) => build(k, {...pathVisited})).toList(),
    );
  }

  final roots = byManager[null] ?? const <Person>[];
  return roots.map((r) => build(r, <String>{})).toList();
}

const _lineColor = Color(0xFFBDBDBD);
const _stemHeight = 18.0;
const _hGap = 28.0;

/// Renders [roots] as a pannable/zoomable org-chart-style tree, connecting
/// each person to their manager with simple straight lines.
class OrgChart extends StatelessWidget {
  const OrgChart({
    super.key,
    required this.roots,
    required this.onTap,
    this.onLongPress,
  });

  final List<PersonNode> roots;
  final void Function(Person) onTap;
  final void Function(Person)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      minScale: 0.5,
      maxScale: 2.0,
      boundaryMargin: const EdgeInsets.all(160),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _SiblingsRow(
          nodes: roots,
          topStems: false,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}

class _SiblingsRow extends StatelessWidget {
  const _SiblingsRow({
    required this.nodes,
    required this.onTap,
    this.onLongPress,
    this.topStems = true,
  });

  final List<PersonNode> nodes;
  final bool topStems;
  final void Function(Person) onTap;
  final void Function(Person)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < nodes.length; i++) ...[
          if (i > 0)
            Padding(
              padding: EdgeInsets.only(top: topStems ? _stemHeight : 0),
              child: Container(width: _hGap, height: 2, color: _lineColor),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (topStems)
                Container(width: 2, height: _stemHeight, color: _lineColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _NodeSubtree(
                  node: nodes[i],
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NodeSubtree extends StatelessWidget {
  const _NodeSubtree({
    required this.node,
    required this.onTap,
    this.onLongPress,
  });

  final PersonNode node;
  final void Function(Person) onTap;
  final void Function(Person)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PersonCard(
          person: node.person,
          onTap: () => onTap(node.person),
          onLongPress: onLongPress == null
              ? null
              : () => onLongPress!(node.person),
        ),
        if (node.children.isNotEmpty) ...[
          Container(width: 2, height: _stemHeight, color: _lineColor),
          _SiblingsRow(
            nodes: node.children,
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ],
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.onTap,
    this.onLongPress,
  });

  final Person person;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  static const _diameter = 68.0;

  @override
  Widget build(BuildContext context) {
    final photoPath = person.photoPath;
    final hasPhoto = photoPath != null && File(photoPath).existsSync();
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        width: 124,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _diameter,
              height: _diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: hasPhoto
                  ? ClipOval(
                      child: Image.file(File(photoPath), fit: BoxFit.cover),
                    )
                  : PersonInitialsBadge(
                      name: person.fullName,
                      size: _diameter,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              person.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            if (person.role != null && person.role!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                person.role!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
