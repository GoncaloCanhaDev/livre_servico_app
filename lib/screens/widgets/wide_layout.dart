import 'package:flutter/material.dart';

import '../../theme.dart';
import 'app_bar_tabs.dart';

/// How many columns of at least [minWidth] fit across this page (at least
/// one). Inside the computer's frame, the page's width is the space beside
/// the side menu (see `AppFrame`).
int columnsFor(BuildContext context, double minWidth, {int max = 4}) =>
    (MediaQuery.sizeOf(context).width / minWidth).floor().clamp(1, max);

/// A page that reads best narrow (a form, a list of settings, a text):
/// centred, [maxWidth] wide at most, on a computer; as it is on a phone.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child, this.maxWidth = 760});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth <= maxWidth) return child;
        // As tall as before, so the page lays out as it does on a phone.
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: maxWidth,
            height: box.hasBoundedHeight ? box.maxHeight : null,
            child: child,
          ),
        );
      },
    );
  }
}

/// [children] in rows of [columns], each the same width, [spacing] apart;
/// a short last row keeps that width. One column is just [children] in a
/// column.
class GridRows extends StatelessWidget {
  const GridRows({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = 8,
    this.divided = false,
  });

  final int columns;
  final List<Widget> children;
  final double spacing;

  /// A thin line between rows (and between people in one column).
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      if (i > 0 && divided) rows.add(const Divider(height: 1));
      final row = children.sublist(i, (i + columns).clamp(0, children.length));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: spacing),
                Expanded(
                  child: j < row.length ? row[j] : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// A screen with tabs, as tabs on a phone and side by side on a computer
/// when there is room: as many columns of [minColumnWidth] as fit, the tabs
/// shared between them in order (a column holding more than one keeps tabs
/// of its own).
class ResponsiveTabs extends StatelessWidget {
  const ResponsiveTabs({
    super.key,
    required this.title,
    required this.tabs,
    this.actions = const [],
    this.minColumnWidth = 380,
    this.scrollable = false,
  });

  final Widget title;
  final List<Widget> actions;

  /// Each tab's name and body.
  final List<(String, Widget)> tabs;
  final double minColumnWidth;

  /// Scrollable tab bar on a phone (long names).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final columns = columnsFor(context, minColumnWidth, max: tabs.length);
    if (columns == 1) {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: title,
            actions: actions,
            bottom: appBarTabs([
              for (final (name, _) in tabs) Tab(text: name),
            ], scrollable: scrollable),
          ),
          body: SafeArea(
            child: TabBarView(children: [for (final (_, b) in tabs) b]),
          ),
        ),
      );
    }
    // Share the tabs out in order, the first columns taking any extra.
    final groups = <List<(String, Widget)>>[];
    var next = 0;
    for (var c = 0; c < columns; c++) {
      final size = tabs.length ~/ columns + (c < tabs.length % columns ? 1 : 0);
      groups.add(tabs.sublist(next, next + size));
      next += size;
    }
    return Scaffold(
      appBar: AppBar(title: title, actions: actions),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, group) in groups.indexed) ...[
              if (i > 0) VerticalDivider(width: 1, color: context.hairline),
              Expanded(child: _TabColumn(group)),
            ],
          ],
        ),
      ),
    );
  }
}

/// One column of [ResponsiveTabs]: a heading, or tabs when it holds several.
class _TabColumn extends StatelessWidget {
  const _TabColumn(this.tabs);

  final List<(String, Widget)> tabs;

  @override
  Widget build(BuildContext context) {
    if (tabs.length == 1) {
      final (name, body) = tabs.single;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeading(name),
          Expanded(child: body),
        ],
      );
    }
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            labelColor: context.colors.onSurface,
            unselectedLabelColor: context.muted,
            indicatorColor: context.colors.primary,
            tabs: [for (final (name, _) in tabs) Tab(text: name)],
          ),
          Expanded(child: TabBarView(children: [for (final (_, b) in tabs) b])),
        ],
      ),
    );
  }
}

/// The title over a column or panel on a computer, with an optional
/// [action] at its end.
class PanelHeading extends StatelessWidget {
  const PanelHeading(this.text, {super.key, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
