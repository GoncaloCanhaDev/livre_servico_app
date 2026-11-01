import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_version.dart';
import '../../services/account_service.dart';
import '../../theme.dart';
import '../destinations.dart';
import 'beta_badge.dart';

/// The app's navigator, so the side menu (outside it) can open pages.
final appNavigatorKey = GlobalKey<NavigatorState>();

/// Which [Destination] is open, for the side menu: the topmost route named
/// after one (null on Home).
class MenuObserver extends NavigatorObserver {
  final current = ValueNotifier<String?>(null);
  final _stack = <Route<dynamic>>[];

  // Routes change while the navigator builds: tell the menu afterwards.
  void _changed() => scheduleMicrotask(() {
    current.value = _stack.reversed
        .map((r) => r.settings.name)
        .whereType<String>()
        .where((n) => n != '/')
        .firstOrNull;
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _changed();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _changed();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _changed();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (newRoute != null) {
      i < 0 ? _stack.add(newRoute) : _stack[i] = newRoute;
    } else if (i >= 0) {
      _stack.removeAt(i);
    }
    _changed();
  }
}

final appMenuObserver = MenuObserver();

/// Whether this page sits beside the computer's side menu, so it needn't
/// repeat its links (Home's buttons).
bool hasSideMenu(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_SideMenuScope>() != null;

class _SideMenuScope extends InheritedWidget {
  const _SideMenuScope({required super.child});

  @override
  bool updateShouldNotify(_SideMenuScope oldWidget) => false;
}

/// The app on a computer's wide screen. With [menu] (once the app is in a
/// store, past Conta) and room for it, a side menu with every page on the
/// left and the page using the rest of the width; otherwise a centred
/// column [maxWidth] wide, on [AppThemeColors.backdrop]. On a phone,
/// [child] as it is.
class AppFrame extends StatelessWidget {
  const AppFrame({super.key, required this.child, this.menu = false});

  static const maxWidth = 840.0;

  /// The narrowest window that gets the side menu.
  static const menuMinWidth = 1100.0;
  static const menuWidth = 240.0;

  final Widget child;
  final bool menu;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (menu && box.maxWidth >= menuMinWidth) {
          final width = box.maxWidth - menuWidth - 1;
          return ColoredBox(
            color: context.colors.surface,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(width: menuWidth, child: _SideMenu()),
                VerticalDivider(width: 1, color: context.hairline),
                Expanded(
                  child: _SideMenuScope(
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(size: Size(width, box.maxHeight)),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (box.maxWidth <= maxWidth + 48) return child;
        return ColoredBox(
          color: context.backdrop,
          child: Center(
            child: Container(
              width: maxWidth,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: context.hairline),
                ),
              ),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: Size(maxWidth, box.maxHeight)),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The computer's side menu: the app's name, then Início and every page.
/// It sits outside the navigator, so it opens pages through
/// [appNavigatorKey], always from Home.
class _SideMenu extends StatelessWidget {
  const _SideMenu();

  void _open(Destination? d) {
    final nav = appNavigatorKey.currentState;
    if (nav == null) return;
    nav.popUntil((r) => r.isFirst);
    if (d != null) nav.push(d.route());
  }

  @override
  Widget build(BuildContext context) {
    final account = AccountService.instance;
    return Material(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            child: ListenableBuilder(
              listenable: account,
              builder: (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Livre Serviço',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      BetaBadge(),
                    ],
                  ),
                  Text(
                    'Companion · v$appVersion',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  if (account.store?.name case final store?) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.store_outlined,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: appMenuObserver.current,
              builder: (context, current, _) => ListenableBuilder(
                listenable: account,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _MenuItem(
                      icon: Icons.home_outlined,
                      label: 'Início',
                      selected: current == null,
                      onTap: () => _open(null),
                    ),
                    for (final d in homeDestinations)
                      _MenuItem(
                        icon: d.icon,
                        label: d.label,
                        selected: current == d.label,
                        onTap: () => _open(d),
                      ),
                    const Divider(indent: 16, endIndent: 16, height: 24),
                    for (final d in [
                      if (account.store?.personId != null) avisosDestination,
                      settingsDestination,
                      tutorialDestination,
                    ])
                      _MenuItem(
                        icon: d.icon,
                        label: d.label,
                        selected: current == d.label,
                        onTap: () => _open(d),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedColor: context.colors.onSurface,
        selectedTileColor: context.hairline,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, size: 22),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
