import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/services/api_service.dart';
//import 'package:mobile/core/strings.dart';
import 'package:mobile/data/models/transaction_model.dart';
import 'package:mobile/data/providers/transaction_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  TransactionModel makeTransaction({
    required String id,
    required double amount,
    required TransactionType type,
    required String category,
    String title = 'Title',
    String note = 'note',
  }) {
    return TransactionModel(
      id: id,
      amount: amount,
      type: type,
      category: category,
      title: title,
      date: DateTime(2025, 1, 1),
      note: note,
    );
  }

  group('TransactionProvider.addTransaction', () {
    test('success: sends correct data to API and returns true', () async {
      final mockApi = MockApiService();
      final tx = makeTransaction(
        id: 'a1',
        amount: 100,
        type: TransactionType.expense,
        category: 'food',
        title: 'Lunch',
      );

      when(() => mockApi.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/transactions'),
          statusCode: 201,
          data: {
            'success': true,
            'data': {...tx.toJson(), '_id': tx.id},
          },
        ),
      );

      final provider = TransactionProvider(apiService: mockApi);
      final result = await provider.addTransaction(tx);

      expect(result, isTrue);
      expect(provider.transactions, hasLength(1));

      final captured =
          verify(
                () => mockApi.post(any(), data: captureAny(named: 'data')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['title'], 'Lunch');
      expect(captured['category'], 'food');
    });

    test('api title error: surfaces backend message clearly', () async {
      final mockApi = MockApiService();
      final tx = makeTransaction(
        id: 'a3',
        amount: 100,
        type: TransactionType.expense,
        category: 'food',
        title: 'Lunch',
      );

      final response = Response(
        requestOptions: RequestOptions(path: '/transactions'),
        statusCode: 400,
        data: {'message': 'Title is required'},
      );

      when(() => mockApi.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/transactions'),
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );

      final provider = TransactionProvider(apiService: mockApi);
      final result = await provider.addTransaction(tx);

      expect(result, isFalse);
      expect(provider.error, 'Title is required');
    });
  });

  group('TransactionProvider.updateTransaction', () {
    test('success: replaces local transaction and returns true', () async {
      final mockApi = MockApiService();

      final original = makeTransaction(
        id: '1',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'food',
        title: 'Lunch',
      );
      final updated = original.copyWith(amount: 150.0, note: 'updated');

      final response = Response(
        requestOptions: RequestOptions(path: '/transactions/1'),
        data: {
          'success': true,
          'data': {...updated.toJson(), '_id': updated.id},
        },
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
      expect(provider.transactions, hasLength(1));
      expect(provider.transactions.first.amount, 150.0);
      expect(provider.error, isEmpty);

      final captured =
          verify(
                () => mockApi.put(any(), data: captureAny(named: 'data')),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['title'], 'Lunch');
      expect(captured['category'], 'food');
    });

    test(
      'server error: rolls back optimistic update and returns false',
      () async {
        final mockApi = MockApiService();

        final original = makeTransaction(
          id: '3',
          amount: 200.0,
          type: TransactionType.income,
          category: 'salary',
          title: 'Salary',
        );
        final updated = original.copyWith(amount: 300.0, note: 'updated');

        final response = Response(
          requestOptions: RequestOptions(path: '/transactions/3'),
          data: {'success': false, 'message': 'error'},
          statusCode: 500,
        );

        when(
          () => mockApi.put(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        final provider = TransactionProvider(
          apiService: mockApi,
          initialTransactions: [original],
        );

        final result = await provider.updateTransaction(updated);

        expect(result, isFalse);
        expect(provider.transactions.first.amount, 200.0);
        expect(provider.error, contains('Cập nhật giao dịch thất bại'));
      },
    );

    test('invalid payload: rolls back and exposes clear parse error', () async {
      final mockApi = MockApiService();

      final original = makeTransaction(
        id: '4',
        amount: 80.0,
        type: TransactionType.expense,
        category: 'travel',
        title: 'Bus',
      );
      final updated = original.copyWith(amount: 120.0, note: 'updated');

      // trả về list thay vì map → provider xử lý fail
      final invalidPayloadResponse = Response(
        requestOptions: RequestOptions(path: '/transactions/4'),
        data: {
          'success': true,
          'data': [updated.toJson()],
        },
        statusCode: 200,
      );

      when(
        () => mockApi.put(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => invalidPayloadResponse);

      final provider = TransactionProvider(
        apiService: mockApi,
        initialTransactions: [original],
      );

      final result = await provider.updateTransaction(updated);

      expect(result, isFalse);
      expect(provider.transactions.first.amount, 80.0);
      expect(provider.error, contains('Phản hồi cập nhật giao dịch không hợp lệ'));
    });

    test('api title error: rolls back and shows backend message', () async {
      final mockApi = MockApiService();
      final original = makeTransaction(
        id: '5',
        amount: 150.0,
        type: TransactionType.expense,
        category: 'food',
        title: 'Dinner',
      );
      final updated = original.copyWith(amount: 180.0);

      final response = Response(
        requestOptions: RequestOptions(path: '/transactions/5'),
        statusCode: 400,
        data: {'message': 'Title is required'},
      );

      when(() => mockApi.put(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/transactions/5'),
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );

      final provider = TransactionProvider(
        apiService: mockApi,
        initialTransactions: [original],
      );

      final result = await provider.updateTransaction(updated);

      expect(result, isFalse);
      expect(provider.transactions.first.amount, 150.0);
      expect(provider.error, 'Title is required');
    });
  });
}
