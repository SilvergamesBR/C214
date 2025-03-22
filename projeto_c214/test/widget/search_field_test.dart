import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_c214/widgets/search_field.dart';

void main() async {
  testWidgets('should set labelText correctly', (WidgetTester tester) async {
    const testLabelText = 'Test Label';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchField(labelText: testLabelText, onSearch: (_) {}),
        ),
      ),
    );

    final inputDecoratorFinder = find.byType(InputDecorator);
    expect(inputDecoratorFinder, findsOneWidget);

    final inputDecorator = tester.widget<InputDecorator>(inputDecoratorFinder);
    final decoration = inputDecorator.decoration;
    expect(decoration.labelText, testLabelText);
  });

  testWidgets('should set hintText correctly', (WidgetTester tester) async {
    const testHintText = 'Test Hint';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchField(hintText: testHintText, onSearch: (_) {}),
        ),
      ),
    );

    final inputDecoratorFinder = find.byType(InputDecorator);
    expect(inputDecoratorFinder, findsOneWidget);

    final inputDecorator = tester.widget<InputDecorator>(inputDecoratorFinder);
    final decoration = inputDecorator.decoration;
    expect(decoration.hintText, testHintText);
  });

  testWidgets('should set helperText correctly', (WidgetTester tester) async {
    const testHelperText = 'Test Helper';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchField(helperText: testHelperText, onSearch: (_) {}),
        ),
      ),
    );

    final inputDecoratorFinder = find.byType(InputDecorator);
    expect(inputDecoratorFinder, findsOneWidget);

    final inputDecorator = tester.widget<InputDecorator>(inputDecoratorFinder);
    final decoration = inputDecorator.decoration;
    expect(decoration.helperText, testHelperText);
  });

  testWidgets('should call onSearch when search button is pressed', (
    WidgetTester tester,
  ) async {
    String? capturedInput;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchField(
            onSearch: (input) {
              capturedInput = input;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Flutter Test');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(capturedInput, 'Flutter Test');
  });

  testWidgets('should allow text input', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SearchField(onSearch: (_) {}))),
    );

    await tester.enterText(find.byType(TextField), 'Testando Input');
    expect(find.text('Testando Input'), findsOneWidget);
  });

  testWidgets('should have an outlined border', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SearchField(onSearch: (_) {}))),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.decoration?.border, isA<OutlineInputBorder>());
  });
}
