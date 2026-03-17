import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/transaction_model.dart';

void main() {
  group('TransactionModel amount parsing', () {
    test('should throw when amount is null', () {
      final json = {'id': '1', 'amount': null, 'type': 'expense'};

      expect(() => TransactionModel.fromJson(json), throwsException);
    });

    test('should throw when amount is invalid string', () {
      final json = {'id': '1', 'amount': 'abc', 'type': 'expense'};

      expect(() => TransactionModel.fromJson(json), throwsException);
    });

    test('should parse valid transaction correctly', () {
      final json = {
        'id': '1',
        'amount': 100,
        'category': 'food',
        'type': 'expense',
      };

      final tx = TransactionModel.fromJson(json);

      expect(tx.amount, 100);
      expect(tx.category, 'food');
    });

    test('should normalize other income to other', () {
      final json = {
        'id': '1',
        'amount': 100,
        'category': 'other income',
        'type': 'income',
      };

      final tx = TransactionModel.fromJson(json);

      expect(tx.category, 'other');
    });

    test('should throw when category is invalid', () {
      final json = {
        'id': '1',
        'amount': 100,
        'category': 'invalid_category',
        'type': 'expense',
      };

      expect(() => TransactionModel.fromJson(json), throwsException);
    });
  });
}
