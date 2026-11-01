import 'package:flutter/material.dart';

/// Tabs for an app bar's `bottom`: white on the black bar, so they never
/// take the theme's colours meant for the page (which would be dark on dark).
/// Tabs in a page's body set their colours from the theme instead.
TabBar appBarTabs(List<Widget> tabs, {bool scrollable = false}) => TabBar(
  isScrollable: scrollable,
  labelColor: Colors.white,
  unselectedLabelColor: Colors.white70,
  indicatorColor: Colors.white,
  dividerColor: Colors.transparent,
  tabs: tabs,
);
