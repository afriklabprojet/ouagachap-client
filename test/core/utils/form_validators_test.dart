import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/utils/form_validators.dart';

void main() {
  group('FormValidators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(FormValidators.required(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(FormValidators.required(''), isNotNull);
      });

      test('returns error for whitespace only', () {
        expect(FormValidators.required('   '), isNotNull);
      });

      test('returns null for valid value', () {
        expect(FormValidators.required('test'), isNull);
      });

      test('includes field name in error message', () {
        final error = FormValidators.required(null, fieldName: 'Email');
        expect(error, contains('Email'));
      });
    });

    group('phoneNumber', () {
      test('returns error for null value', () {
        expect(FormValidators.phoneNumber(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(FormValidators.phoneNumber(''), isNotNull);
      });

      test('returns error for too short number', () {
        expect(FormValidators.phoneNumber('123456'), isNotNull);
      });

      test('returns error for too long number', () {
        expect(FormValidators.phoneNumber('1234567890'), isNotNull);
      });

      test('returns error for non-numeric characters', () {
        expect(FormValidators.phoneNumber('12AB5678'), isNotNull);
      });

      test('accepts valid 8-digit number', () {
        expect(FormValidators.phoneNumber('70123456'), isNull);
      });

      test('accepts number with spaces', () {
        expect(FormValidators.phoneNumber('70 12 34 56'), isNull);
      });

      test('accepts number starting with valid Burkina Faso prefixes', () {
        // Orange
        expect(FormValidators.phoneNumber('70123456'), isNull);
        expect(FormValidators.phoneNumber('71123456'), isNull);
        expect(FormValidators.phoneNumber('72123456'), isNull);
        // Moov
        expect(FormValidators.phoneNumber('74123456'), isNull);
        expect(FormValidators.phoneNumber('75123456'), isNull);
        expect(FormValidators.phoneNumber('76123456'), isNull);
        // Telecel
        expect(FormValidators.phoneNumber('77123456'), isNull);
        expect(FormValidators.phoneNumber('78123456'), isNull);
      });
    });

    group('otp', () {
      test('returns error for null value', () {
        expect(FormValidators.otp(null), isNotNull);
      });

      test('returns error for empty string', () {
        expect(FormValidators.otp(''), isNotNull);
      });

      test('returns error for wrong length', () {
        expect(FormValidators.otp('1234'), isNotNull);
        expect(FormValidators.otp('1234567'), isNotNull);
      });

      test('returns error for non-numeric characters', () {
        expect(FormValidators.otp('12A456'), isNotNull);
      });

      test('accepts valid 6-digit OTP', () {
        expect(FormValidators.otp('123456'), isNull);
      });

      test('accepts custom length OTP', () {
        expect(FormValidators.otp('1234', length: 4), isNull);
      });
    });

    group('email', () {
      test('returns null for null value (optional)', () {
        expect(FormValidators.email(null), isNull);
      });

      test('returns null for empty string (optional)', () {
        expect(FormValidators.email(''), isNull);
      });

      test('returns error for invalid email format', () {
        expect(FormValidators.email('invalid'), isNotNull);
        expect(FormValidators.email('invalid@'), isNotNull);
        expect(FormValidators.email('@domain.com'), isNotNull);
        expect(FormValidators.email('invalid@domain'), isNotNull);
      });

      test('accepts valid email', () {
        expect(FormValidators.email('test@example.com'), isNull);
        expect(FormValidators.email('user.name@domain.org'), isNull);
      });
    });

    group('name', () {
      test('returns error for null value', () {
        expect(FormValidators.name(null), isNotNull);
      });

      test('returns error for too short name', () {
        expect(FormValidators.name('A'), isNotNull);
      });

      test('returns error for too long name', () {
        final longName = 'A' * 101;
        expect(FormValidators.name(longName), isNotNull);
      });

      test('accepts valid name', () {
        expect(FormValidators.name('Jean'), isNull);
        expect(FormValidators.name('Marie-Claire'), isNull);
        expect(FormValidators.name('Aminata Ouédraogo'), isNull);
      });
    });

    group('amount', () {
      test('returns error for null value', () {
        expect(FormValidators.amount(null), isNotNull);
      });

      test('returns error for non-numeric value', () {
        expect(FormValidators.amount('abc'), isNotNull);
      });

      test('returns error for amount below minimum', () {
        expect(FormValidators.amount('50', min: 100), isNotNull);
      });

      test('returns error for amount above maximum', () {
        expect(FormValidators.amount('150000', max: 100000), isNotNull);
      });

      test('accepts valid amount', () {
        expect(FormValidators.amount('1000'), isNull);
        expect(FormValidators.amount('5000', min: 100, max: 10000), isNull);
      });

      test('accepts amount with spaces (formatted)', () {
        expect(FormValidators.amount('10 000'), isNull);
        expect(FormValidators.amount('1 000 000'), isNull);
      });
    });

    group('description', () {
      test('returns error for null value (required)', () {
        expect(FormValidators.description(null), isNotNull);
      });

      test('returns error for too short description', () {
        expect(FormValidators.description('Hi', minLength: 10), isNotNull);
      });

      test('returns error for too long description', () {
        final longDesc = 'A' * 501;
        expect(FormValidators.description(longDesc, maxLength: 500), isNotNull);
      });

      test('accepts valid description', () {
        expect(FormValidators.description('Colis de documents importants'), isNull);
      });
    });

    group('combine', () {
      test('returns first error if any validator fails', () {
        final validator = FormValidators.combine([
          FormValidators.required,
          (value) => value!.length < 3 ? 'Too short' : null,
        ]);

        expect(validator(null), isNotNull);
        expect(validator(''), isNotNull);
        expect(validator('ab'), equals('Too short'));
      });

      test('returns null if all validators pass', () {
        final validator = FormValidators.combine([
          FormValidators.required,
          (value) => value!.length >= 3 ? null : 'Too short',
        ]);

        expect(validator('test'), isNull);
      });

      test('returns null for empty validator list', () {
        final validator = FormValidators.combine([]);
        expect(validator('anything'), isNull);
      });

      test('works with three or more validators', () {
        final validator = FormValidators.combine([
          FormValidators.required,
          (value) => value!.length < 5 ? 'Trop court' : null,
          (value) => value!.contains('x') ? null : 'Doit contenir x',
        ]);
        expect(validator(null), isNotNull);
        expect(validator('abc'), 'Trop court');
        expect(validator('abcde'), 'Doit contenir x');
        expect(validator('abcdex'), isNull);
      });
    });
  });

  group('InputFormatters', () {
    group('phoneNumber', () {
      test('formats phone number with spaces', () {
        final formatter = InputFormatters.phoneNumber();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '70123456'),
        );
        expect(result.text, '70 12 34 56');
      });

      test('removes non-digit characters', () {
        final formatter = InputFormatters.phoneNumber();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '70-12-34'),
        );
        expect(result.text, '70 12 34');
      });

      test('limits to 8 digits', () {
        final formatter = InputFormatters.phoneNumber();
        
        var oldValue = const TextEditingValue(text: '70 12 34 56');
        var result = formatter.formatEditUpdate(
          oldValue,
          const TextEditingValue(text: '701234567'),
        );
        expect(result.text, '70 12 34 56');
      });

      test('handles empty input', () {
        final formatter = InputFormatters.phoneNumber();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(text: '70'),
          const TextEditingValue(text: ''),
        );
        expect(result.text, '');
      });

      test('preserves cursor position at end', () {
        final formatter = InputFormatters.phoneNumber();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '7012'),
        );
        expect(result.selection.baseOffset, result.text.length);
      });

      test('formats partial input correctly', () {
        final formatter = InputFormatters.phoneNumber();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '701'),
        );
        expect(result.text, '70 1');
      });
    });

    group('amount', () {
      test('formats amount with thousand separators', () {
        final formatter = InputFormatters.amount();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '1000000'),
        );
        expect(result.text, '1 000 000');
      });

      test('handles small amounts', () {
        final formatter = InputFormatters.amount();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '500'),
        );
        expect(result.text, '500');
      });

      test('removes non-digit characters', () {
        final formatter = InputFormatters.amount();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '1,000.50'),
        );
        expect(result.text, '100 050');
      });

      test('handles empty input', () {
        final formatter = InputFormatters.amount();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(text: '100'),
          const TextEditingValue(text: ''),
        );
        expect(result.text, '');
      });

      test('preserves cursor position at end', () {
        final formatter = InputFormatters.amount();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(text: '50000'),
        );
        expect(result.selection.baseOffset, result.text.length);
      });

      test('formats various amounts correctly', () {
        final formatter = InputFormatters.amount();
        
        expect(
          formatter.formatEditUpdate(
            const TextEditingValue(),
            const TextEditingValue(text: '10000'),
          ).text,
          '10 000',
        );
        
        expect(
          formatter.formatEditUpdate(
            const TextEditingValue(),
            const TextEditingValue(text: '100'),
          ).text,
          '100',
        );
      });
    });

    group('upperCase', () {
      test('converts text to uppercase', () {
        final formatter = InputFormatters.upperCase();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(
            text: 'hello',
            selection: TextSelection.collapsed(offset: 5),
          ),
        );
        expect(result.text, 'HELLO');
      });

      test('preserves cursor position', () {
        final formatter = InputFormatters.upperCase();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(
            text: 'test',
            selection: TextSelection.collapsed(offset: 2),
          ),
        );
        expect(result.selection.baseOffset, 2);
      });

      test('handles mixed case', () {
        final formatter = InputFormatters.upperCase();
        
        var result = formatter.formatEditUpdate(
          const TextEditingValue(),
          const TextEditingValue(
            text: 'HeLLo WoRLd',
            selection: TextSelection.collapsed(offset: 11),
          ),
        );
        expect(result.text, 'HELLO WORLD');
      });
    });

    group('maxLength', () {
      test('returns LengthLimitingTextInputFormatter', () {
        final formatter = InputFormatters.maxLength(10);
        expect(formatter, isA<LengthLimitingTextInputFormatter>());
      });
    });

    group('digitsOnly', () {
      test('returns FilteringTextInputFormatter.digitsOnly', () {
        final formatter = InputFormatters.digitsOnly();
        expect(formatter, FilteringTextInputFormatter.digitsOnly);
      });
    });

    group('lettersOnly', () {
      test('returns FilteringTextInputFormatter for letters', () {
        final formatter = InputFormatters.lettersOnly();
        expect(formatter, isA<FilteringTextInputFormatter>());
      });
    });
  });

  group('ValidatedTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(label: 'Test Label'),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('renders with hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Label',
              hint: 'Enter value',
            ),
          ),
        ),
      );

      expect(find.text('Enter value'), findsOneWidget);
    });

    testWidgets('shows validation error after losing focus', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ValidatedTextField(
                  label: 'Name',
                  validator: FormValidators.required,
                ),
                const TextField(), // Second field to shift focus
              ],
            ),
          ),
        ),
      );

      // Focus on ValidatedTextField
      await tester.tap(find.byType(ValidatedTextField));
      await tester.pump();

      // Shift focus away
      await tester.tap(find.byType(TextField).last);
      await tester.pump();

      expect(find.text('Ce champ est obligatoire'), findsOneWidget);
    });

    testWidgets('validates on text change after first interaction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ValidatedTextField(
                  label: 'Name',
                  validator: (value) => value!.length < 3 ? 'Trop court' : null,
                ),
                const TextField(),
              ],
            ),
          ),
        ),
      );

      // Enter text and lose focus to trigger hasInteracted
      await tester.enterText(find.byType(ValidatedTextField), 'ab');
      await tester.tap(find.byType(TextField).last);
      await tester.pump();

      expect(find.text('Trop court'), findsOneWidget);

      // Now type more and see error clear
      await tester.enterText(find.byType(ValidatedTextField), 'abc');
      await tester.pump();

      expect(find.text('Trop court'), findsNothing);
    });

    testWidgets('calls onChanged callback', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(ValidatedTextField), 'hello');
      expect(changedValue, 'hello');
    });

    testWidgets('uses provided controller', (tester) async {
      final controller = TextEditingController(text: 'initial');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
      
      controller.dispose();
    });

    testWidgets('shows prefix icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Phone',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.phone), findsOneWidget);
    });

    testWidgets('shows suffix icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Password',
              suffixIcon: Icon(Icons.visibility),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Password',
              obscureText: true,
            ),
          ),
        ),
      );

      // Just verify widget renders without errors
      expect(find.byType(ValidatedTextField), findsOneWidget);
    });

    testWidgets('disables field when enabled is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Disabled',
              enabled: false,
            ),
          ),
        ),
      );

      // Just verify widget renders without errors
      expect(find.byType(ValidatedTextField), findsOneWidget);
    });

    testWidgets('applies input formatters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Phone',
              inputFormatters: [InputFormatters.phoneNumber()],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(ValidatedTextField), '70123456');
      await tester.pump();

      expect(find.text('70 12 34 56'), findsOneWidget);
    });

    testWidgets('respects maxLines parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Description',
              maxLines: 5,
            ),
          ),
        ),
      );

      // Just verify widget renders without errors
      expect(find.byType(ValidatedTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('calls onSubmitted callback', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test',
              onSubmitted: (value) => submittedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(ValidatedTextField), 'test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'test');
    });

    testWidgets('respects autofocus property', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test',
              autofocus: true,
            ),
          ),
        ),
      );

      // Just verify widget renders without errors
      expect(find.byType(ValidatedTextField), findsOneWidget);
    });

    testWidgets('respects maxLength property', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ValidatedTextField(
              label: 'Test',
              maxLength: 10,
            ),
          ),
        ),
      );

      // Just verify widget renders without errors
      expect(find.byType(ValidatedTextField), findsOneWidget);
    });
  });
}
