import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lista_telefonica/models/contatos_model.dart';
import 'package:lista_telefonica/my_app.dart';
import 'package:lista_telefonica/pages/home_page.dart';
import 'package:lista_telefonica/repositories/contatos_back4app_repository.dart';
import 'package:lista_telefonica/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {});
  group('Home Page E2E Test', () {
    testWidgets('Testando carregamento da página', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      app.main();
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Teste adicionar um contato', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      app.main();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);

      final addBotao = find.byIcon(Icons.add);
      expect(addBotao, findsOneWidget);
      await tester.tap(addBotao);
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('nomeTextField')), 'NovoNome');
      await tester.enterText(
          find.byKey(const Key('sobrenomeTextField')), 'NovoSobrenome');
      await tester.tap(find.byKey(const Key('dropdownKey')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Celular').last);
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('numeroTextField')), '12 34567895');

      final textEmail = await tester.enterText(
          find.byKey(const Key('emailTextField')), 'novonome@test.com');
      //await tester.testTextInput.receiveAction(TextInputAction.done);
      //await tester.pump();
      final botaoSalvar = find.byKey(const Key('salvar'));
      await tester.tap(botaoSalvar);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
