import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_app/main.dart';
import 'package:student_app/models/student.dart';
import 'package:student_app/pages/students_page.dart';

void main() {
  group("Widget Test", () {
    testWidgets('Student Row', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StudentRow(
                Student("Test Name", "Test Surname", 18, false),
              ),
            ),
          ),
        ),
      );

      // Verify Icons.
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap the fav icon and trigger.
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Reverse.
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // Tap the fav icon and trigger.
      await tester.tap(find.byType(IconButton));
      await tester.pump();
    });
  });
}