import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/view/profile_screen.dart';

void main() {
  setUp(() async {
    GetIt.I.allowReassignment = true;
    // register a CollaboratorController instance
    final collController = CollaboratorController();
    GetIt.I.registerSingleton<CollaboratorController>(collController);
    // register AuthController (depends on CollaboratorController)
    final authController = AuthController();
    GetIt.I.registerSingleton<AuthController>(authController);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('Save button disabled initially and with invalid phone/email, enabled when valid and changed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    // open popup menu
    final menuFinder = find.byIcon(Icons.more_vert);
    expect(menuFinder, findsOneWidget);
    await tester.tap(menuFinder);
    await tester.pumpAndSettle();

    // tap 'Editar perfil'
    final editFinder = find.text('Editar perfil');
    expect(editFinder, findsOneWidget);
    await tester.tap(editFinder);
    await tester.pumpAndSettle();

    // find Save button
    final saveFinder = find.widgetWithText(ElevatedButton, 'Salvar');
    expect(saveFinder, findsOneWidget);
    var saveWidget = tester.widget<ElevatedButton>(saveFinder);
    // initially should be disabled because no changes
    expect(saveWidget.onPressed, isNull);

  // find email and phone fields by order (two TextFormFields: email then phone)
  final tfFinder = find.byType(TextFormField);
  expect(tfFinder, findsNWidgets(2));
  final emailField = tfFinder.at(0);
  final phoneField = tfFinder.at(1);

    // enter invalid email and invalid phone
    await tester.enterText(emailField, 'invalid-email');
    await tester.enterText(phoneField, '123');
    await tester.pumpAndSettle();

  saveWidget = tester.widget<ElevatedButton>(saveFinder);
  expect(saveWidget.onPressed, isNull, reason: 'Save should be disabled with invalid email and phone');
  // validation messages should appear
  expect(find.text('Email inválido.'), findsOneWidget);
  expect(find.textContaining('Telefone inválido'), findsOneWidget);

    // enter valid email but invalid phone
    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(phoneField, '123');
    await tester.pumpAndSettle();

  saveWidget = tester.widget<ElevatedButton>(saveFinder);
  expect(saveWidget.onPressed, isNull, reason: 'Save should be disabled when phone invalid');
  // email should be valid now
  expect(find.text('Email inválido.'), findsNothing);
  expect(find.textContaining('Telefone inválido'), findsOneWidget);

    // enter valid phone (10 digits)
    await tester.enterText(phoneField, '(11) 91234-5678');
    await tester.pumpAndSettle();

  saveWidget = tester.widget<ElevatedButton>(saveFinder);
  // validators should be clear
  expect(find.text('Email inválido.'), findsNothing);
  expect(find.textContaining('Telefone inválido'), findsNothing);
  });
}
