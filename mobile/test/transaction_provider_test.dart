import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';

import 'package:mobile/data/providers/transaction_provider.dart';
import 'package:mobile/data/models/transaction_model.dart';
import 'package:mobile/core/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  group('TransactionProvider.updateTransaction', () {
    test(
      'successful update replaces local transaction and returns true',
      () async {
        final mockApi = MockApiService();

        final original = TransactionModel(
          id: '1',
          amount: 100.0,
          type: TransactionType.expense,
          category: 'food',
          title: 'Lunch',
          date: DateTime.now(),
          note: 'note',
        );

        final updated = original.copyWith(amount: 150.0, note: 'updated');

        // Mock API response
        final response = Response(
          requestOptions: RequestOptions(path: '/transactions/1'),
          data: {'success': true, 'data': updated.toJson()},
          statusCode: 200,
        );

        when(
          () => mockApi.put(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        final provider = TransactionProvider(
          apiService: mockApi,
          initialTransactions: [original],
        );

        final result = await provider.updateTransaction(updated);

        expect(result, isTrue);
        expect(provider.transactions.length, 1);
        expect(provider.transactions.first.amount, 150.0);
      },
    );

    test(
      'failed update rolls back optimistic change and returns false',
      () async {
        final mockApi = MockApiService();

        final original = TransactionModel(
          id: '2',
          amount: 200.0,
          type: TransactionType.income,
          category: 'salary',
          title: 'Salary',
          date: DateTime.now(),
          note: 'note',
        );

        final updated = original.copyWith(amount: 300.0, note: 'updated');

        when(
          () => mockApi.put(any(), data: any(named: 'data')),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '/')));

        final provider = TransactionProvider(
          apiService: mockApi,
          initialTransactions: [original],
        );

        final result = await provider.updateTransaction(updated);

        expect(result, isFalse);
        expect(provider.transactions.length, 1);
        expect(provider.transactions.first.amount, 200.0); // rolled back
      },
    );
  });
}
