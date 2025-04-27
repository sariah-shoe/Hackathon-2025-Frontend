import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serendipity_engine/presentation/screens/create_account.dart'; // Adjust import path if needed

// Mocks for the callback functions
class MockOnDataChanged extends Mock {
  void call(Map<String, dynamic> data);
}

class MockOnValidityChanged extends Mock {
  void call(bool isValid);
}

void main() {
  // Declare mocks
  late MockOnDataChanged mockOnDataChanged;
  late MockOnValidityChanged mockOnValidityChanged;

  // Helper function to pump the widget
  Future<void> pumpCreateAccountScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp( // Need MaterialApp for theme/directionality
        home: Scaffold( // Need Scaffold for structure if screen uses it implicitly
          body: CreateAccountScreen(
            onDataChanged: mockOnDataChanged,
            onValidityChanged: mockOnValidityChanged,
          ),
        ),
      ),
    );
  }

  setUp(() {
    // Initialize mocks before each test
    mockOnDataChanged = MockOnDataChanged();
    mockOnValidityChanged = MockOnValidityChanged();

    // Register fallback values for any() matchers if needed
    registerFallbackValue(<String, dynamic>{}); // For onDataChanged
  });

  group('CreateAccountScreen Widget Tests', () {
    testWidgets('renders required fields initially', (WidgetTester tester) async {
      await pumpCreateAccountScreen(tester);

      // Verify required fields are present
      expect(find.widgetWithText(TextFormField, 'Email *'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password *'), findsOneWidget);

      // Verify some optional fields are present
      expect(find.widgetWithText(TextFormField, 'First Name'), findsOneWidget);
      expect(find.widgetWithText(DropdownButtonFormField<String>, 'Year in School'), findsOneWidget);
      expect(find.text('Majors'), findsOneWidget); // Chip group label

      // Verify initial validity callback (should be false)
      // Need pumpAndSettle after initial build for async operations like addPostFrameCallback
      await tester.pumpAndSettle();
      verify(() => mockOnValidityChanged(false)).called(1);
      verifyNever(() => mockOnDataChanged(any())); // Data shouldn't be sent initially
    });

    testWidgets('shows validation errors for empty required fields', (WidgetTester tester) async {
      await pumpCreateAccountScreen(tester);
      await tester.pumpAndSettle(); // Ensure initial state is settled

      // Try entering text in an optional field to trigger validation check via _checkValidity
      await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Test');
      await tester.pump(); // Re-render after text input

      // Verify validation errors appear for required fields
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);

      // Validity should still be false
      // It might be called multiple times due to listener/onChanged, check at least once
      verify(() => mockOnValidityChanged(false)).called(greaterThanOrEqualTo(1));
      verifyNever(() => mockOnDataChanged(any()));
    });

     testWidgets('shows validation error for invalid email format', (WidgetTester tester) async {
      await pumpCreateAccountScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email *'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password *'), 'password123'); // Valid password
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Password is required'), findsNothing); // Password error should disappear

      verify(() => mockOnValidityChanged(false)).called(greaterThanOrEqualTo(1));
       verifyNever(() => mockOnDataChanged(any()));
    });

     testWidgets('shows validation error for short password', (WidgetTester tester) async {
      await pumpCreateAccountScreen(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email *'), 'valid@email.com'); // Valid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Password *'), 'short'); // Invalid password
      await tester.pump();

      expect(find.text('Enter a valid email'), findsNothing);
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);

      verify(() => mockOnValidityChanged(false)).called(greaterThanOrEqualTo(1));
       verifyNever(() => mockOnDataChanged(any()));
    });

    testWidgets('calls onValidityChanged(true) and onDataChanged when required fields are valid', (WidgetTester tester) async {
      await pumpCreateAccountScreen(tester);
      await tester.pumpAndSettle(); // Settle initial state

      // Clear initial false call count
      clearInteractions(mockOnValidityChanged);
      clearInteractions(mockOnDataChanged);

      // Enter valid data
      await tester.enterText(find.widgetWithText(TextFormField, 'Email *'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password *'), 'password123');
      await tester.pump(); // Trigger listeners and validation

      // Verify validity becomes true
      verify(() => mockOnValidityChanged(true)).called(1);

      // Verify data is sent
      final captured = verify(() => mockOnDataChanged(captureAny())).captured;
      expect(captured.length, 1);
      final data = captured.first as Map<String, dynamic>;
      expect(data['email'], 'test@example.com');
      expect(data['password'], 'password123');
      // Check other fields are present even if empty/null initially
      expect(data.containsKey('first_name'), isTrue);
      expect(data.containsKey('last_name'), isTrue);
      expect(data.containsKey('image_path'), isTrue);
      expect(data.containsKey('year_in_school'), isTrue);
      // ... check other keys

      // Enter invalid data again
      await tester.enterText(find.widgetWithText(TextFormField, 'Password *'), 'short');
      await tester.pump();

      // Verify validity becomes false again
      verify(() => mockOnValidityChanged(false)).called(1);
      // Data should not be sent when invalid (verify no *new* calls)
       verifyNever(() => mockOnDataChanged(any()));
    });

     testWidgets('updates data map when optional fields change (while valid)', (WidgetTester tester) async {
      await pumpCreateAccountScreen(tester);
      await tester.pumpAndSettle();

      // Make the form valid first
      await tester.enterText(find.widgetWithText(TextFormField, 'Email *'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password *'), 'password123');
      await tester.pump();

      // Clear initial interactions
      clearInteractions(mockOnDataChanged);

      // Change an optional field (First Name)
      await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Jane');
      await tester.pump();

      // Verify data is sent again with the update
      final captured = verify(() => mockOnDataChanged(captureAny())).captured;
      expect(captured.length, 1);
      final data = captured.first as Map<String, dynamic>;
      expect(data['email'], 'test@example.com');
      expect(data['password'], 'password123');
      expect(data['first_name'], 'Jane'); // Check updated value
      expect(data['last_name'], ''); // Check other optional field

       // Change another optional field (select a Major chip)
       clearInteractions(mockOnDataChanged);
       await tester.tap(find.widgetWithText(FilterChip, 'Computer Science'));
       await tester.pump();

       final captured2 = verify(() => mockOnDataChanged(captureAny())).captured;
       expect(captured2.length, 1);
       final data2 = captured2.first as Map<String, dynamic>;
       expect(data2['majors'], contains('Computer Science'));
    });

    // TODO: Add tests for image picker interaction (might require more complex mocking)
    // TODO: Add tests for selecting dropdown values and verifying data update
    // TODO: Add tests for selecting/deselecting multiple chips
  });
}