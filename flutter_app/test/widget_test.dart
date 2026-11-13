import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glowup_flutter/main.dart';

void main() {
  testWidgets('Login e Cadastro iniciam vazios apenas com placeholders', (WidgetTester tester) async {
    await tester.pumpWidget(const GlowUpApp());
    expect(find.text('Bem-vindo ao GlowUp'), findsOneWidget);
    final textFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    for (final field in textFields) {
      expect(field.controller?.text ?? '', isEmpty);
    }
  });
}
