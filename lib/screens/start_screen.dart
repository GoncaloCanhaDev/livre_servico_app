import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/account_service.dart';
import 'account_screen.dart';
import 'home_screen.dart';

/// Whether the app opens on Conta rather than Home: on the website, until
/// the account is signed in and connected to an approved store (there is
/// nothing to show there without one). The phone works signed out as ever;
/// so does a build without the online database.
bool needsAccountFirst({
  required bool web,
  required bool configured,
  required bool signedIn,
  required StoreInfo? store,
}) => web && configured && (!signedIn || store == null || store.pending);

/// The store to open on its own after signing in, without a list to pick
/// from: everyone but the admin belongs to one store.
StoreInfo? storeToOpen(List<StoreInfo> stores, {required bool admin}) =>
    !admin && stores.length == 1 ? stores.single : null;

/// The app's first page: Conta while [needsAccountFirst], then Home.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = AccountService.instance;
    return ListenableBuilder(
      listenable: account,
      builder: (_, _) =>
          needsAccountFirst(
            web: kIsWeb,
            configured: account.isConfigured,
            signedIn: account.isSignedIn,
            store: account.store,
          )
          ? const AccountScreen()
          : const HomeScreen(),
    );
  }
}
