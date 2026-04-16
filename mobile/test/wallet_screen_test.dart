import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/services/wallet_api_service.dart';
import 'package:mobile/data/providers/wallet_provider.dart';
import 'package:mobile/views/wallet/wallet_screen.dart';

class FakeWalletApiService implements WalletApiService {
  FakeWalletApiService(this.walletsResponse);

  final GetWalletsResponse walletsResponse;

  @override
  Future<GetWalletsResponse> getAllWallets() async => walletsResponse;

  @override
  Future<TransferResponse> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    String? note,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<GetWalletResponse> getWalletById(String walletId) {
    throw UnimplementedError();
  }

  @override
  Future<UpdateWalletResponse> updateWallet({
    required String walletId,
    String? name,
    String? description,
  }) {
    throw UnimplementedError();
  }
}

WalletData walletData({
  required String id,
  required String walletType,
  required int balance,
  required String name,
}) {
  return WalletData(
    id: id,
    userId: 'u1',
    walletType: walletType,
    balance: balance,
    name: name,
    description: '',
    lastUpdated: DateTime.now().toIso8601String(),
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WalletScreen renders wallets and total balance', (tester) async {
    final provider = WalletProvider(
      apiService: FakeWalletApiService(
        GetWalletsResponse(
          success: true,
          data: [
            walletData(
              id: 'cash-id',
              walletType: 'cash',
              balance: 300000,
              name: 'Tiền mặt',
            ),
            walletData(
              id: 'bank-id',
              walletType: 'bank',
              balance: 90000,
              name: 'Ngân hàng',
            ),
          ],
          totalBalance: 390000,
        ),
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<WalletProvider>.value(
        value: provider,
        child: const MaterialApp(home: WalletScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ví của tôi'), findsOneWidget);
    expect(find.text('Danh sách ví'), findsOneWidget);
    expect(find.text('Tiền mặt'), findsOneWidget);
    expect(find.text('Ngân hàng'), findsOneWidget);
    expect(find.textContaining('390'), findsWidgets);
    expect(find.textContaining('₫'), findsWidgets);
  });

  testWidgets(
    'WalletScreen opens transfer modal when tapping transfer button',
    (tester) async {
      final provider = WalletProvider(
        apiService: FakeWalletApiService(
          GetWalletsResponse(
            success: true,
            data: [
              walletData(
                id: 'cash-id',
                walletType: 'cash',
                balance: 300000,
                name: 'Tiền mặt',
              ),
              walletData(
                id: 'bank-id',
                walletType: 'bank',
                balance: 90000,
                name: 'Ngân hàng',
              ),
            ],
            totalBalance: 390000,
          ),
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<WalletProvider>.value(
          value: provider,
          child: const MaterialApp(home: WalletScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Điều chuyển'));
      await tester.pumpAndSettle();

      expect(find.text('Điều chuyển tiền'), findsOneWidget);
      expect(find.text('Từ ví'), findsOneWidget);
      expect(find.text('Đến ví'), findsOneWidget);
    },
  );
}
