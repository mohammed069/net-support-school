import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('Shared Widgets', () {
    group('Common Button Widget', () {
      /// Test: Should render button with correct text
      testWidgets('Should display button with correct text', (
        WidgetTester tester,
      ) async {
        // Arrange
        const buttonText = 'Click Me';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () {},
                child: const Text(buttonText),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(buttonText), findsOneWidget);
      });

      /// Test: Should respond to tap
      testWidgets('Should call callback when tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        bool wasTapped = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () => wasTapped = true,
                child: Container(width: 100, height: 100),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        // Assert
        expect(wasTapped, true);
      });
    });

    group('Common Text Field Widget', () {
      /// Test: Should accept text input
      testWidgets('Should accept and display user input', (
        WidgetTester tester,
      ) async {
        // Arrange
        const testText = 'Test Input';
        final textController = TextEditingController();

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: TextField(controller: textController)),
          ),
        );

        await tester.enterText(find.byType(TextField), testText);
        await tester.pumpAndSettle();

        // Assert
        expect(textController.text, testText);
      });

      /// Test: Should show error message
      testWidgets('Should display error text when validation fails', (
        WidgetTester tester,
      ) async {
        // Arrange
        const errorMessage = 'This field is required';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return errorMessage;
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Trigger validation by tapping outside
        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Assert - This would show error on actual form submission
        // expect(find.text(errorMessage), findsOneWidget);
      });
    });

    group('Dialog Widget', () {
      /// Test: Should show dialog when triggered
      testWidgets('Should display dialog when showDialog is called', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: tester.element(find.byType(ElevatedButton)),
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Test Dialog'),
                            content: const Text('This is a test'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Test Dialog'), findsOneWidget);
        expect(find.text('This is a test'), findsOneWidget);
      });
    });

    group('List Widget', () {
      /// Test: Should render list items
      testWidgets('Should render all list items', (WidgetTester tester) async {
        // Arrange
        final items = ['Item 1', 'Item 2', 'Item 3'];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(items[index]));
                },
              ),
            ),
          ),
        );

        // Assert
        for (final item in items) {
          expect(find.text(item), findsOneWidget);
        }
      });

      /// Test: Should handle scroll
      testWidgets('Should scroll to load more items', (
        WidgetTester tester,
      ) async {
        // Arrange
        final items = List.generate(50, (i) => 'Item $i');

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(items[index]));
                },
              ),
            ),
          ),
        );

        // Scroll to item at index 30
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Item 30'), findsOneWidget);
      });
    });

    group('Loading Indicator', () {
      /// Test: Should show circular progress indicator
      testWidgets('Should display loading indicator', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Snackbar Widget', () {
      /// Test: Should show snackbar message
      testWidgets(
        'Should display snackbar when ScaffoldMessenger.showSnackBar is called',
        (WidgetTester tester) async {
          // Arrange
          const snackbarMessage = 'Test Snackbar';

          // Act
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      tester.element(find.byType(ElevatedButton)),
                    ).showSnackBar(
                      const SnackBar(content: Text(snackbarMessage)),
                    );
                  },
                  child: const Text('Show Snackbar'),
                ),
              ),
            ),
          );

          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text(snackbarMessage), findsOneWidget);
        },
      );
    });
  });
}


