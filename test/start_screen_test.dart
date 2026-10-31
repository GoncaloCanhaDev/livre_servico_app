import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/screens/start_screen.dart';
import 'package:livre_servico_app/services/account_service.dart';

void main() {
  StoreInfo store({bool pending = false}) => (
    id: 's1',
    name: 'Loja',
    role: StoreRole.editor,
    personId: null,
    pending: pending,
    access: const StoreAccess(admin: false),
  );

  bool first({
    bool web = true,
    bool configured = true,
    bool signedIn = true,
    StoreInfo? chosen,
  }) => needsAccountFirst(
    web: web,
    configured: configured,
    signedIn: signedIn,
    store: chosen,
  );

  test('the website opens on Conta until a store is connected', () {
    expect(first(signedIn: false), isTrue);
    expect(first(), isTrue);
    expect(first(chosen: store(pending: true)), isTrue);
    expect(first(chosen: store()), isFalse);
  });

  test('the phone opens on Home, signed in or not', () {
    expect(first(web: false, signedIn: false), isFalse);
    expect(first(web: false), isFalse);
  });

  test('a website build without the database opens on Home', () {
    expect(first(configured: false, signedIn: false), isFalse);
  });

  group('firstPage', () {
    FirstPage page({
      bool web = true,
      bool configured = true,
      bool signedIn = false,
      StoreInfo? chosen,
      bool demo = false,
    }) => firstPage(
      web: web,
      configured: configured,
      signedIn: signedIn,
      store: chosen,
      demo: demo,
    );

    test('a visitor of the website sees the presentation', () {
      expect(page(), FirstPage.presentation);
    });

    test('signed in without a store: Conta, as before', () {
      expect(page(signedIn: true), FirstPage.account);
      expect(
        page(signedIn: true, chosen: store(pending: true)),
        FirstPage.account,
      );
      expect(page(signedIn: true, chosen: store()), FirstPage.home);
    });

    test('the demo and the phone open on Home', () {
      expect(page(demo: true), FirstPage.home);
      expect(page(web: false), FirstPage.home);
      expect(page(configured: false), FirstPage.home);
    });
  });

  test("everyone but the admin opens their one store at once", () {
    expect(storeToOpen([store()], admin: false)?.id, 's1');
    expect(storeToOpen([store()], admin: true), isNull);
    expect(storeToOpen([], admin: false), isNull);
    expect(storeToOpen([store(), store()], admin: false), isNull);
  });
}
