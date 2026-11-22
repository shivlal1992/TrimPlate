
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trimplate/main.dart';

void main() {
  testWidgets('TrimPlate app loads successfully', (tester) async {
    await tester.pumpWidget(
      const TrimPlateApp(loggedIn: false),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('TRIMPLATE'), findsOneWidget);
    expect(find.text('Continue with Mobile'), findsOneWidget);
  });
}
