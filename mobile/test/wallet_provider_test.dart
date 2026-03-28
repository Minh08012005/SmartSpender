import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/wallet_api_service.dart';
import 'package:mobile/data/providers/wallet_provider.dart';

class FakeWalletApiService implements WalletApiService {
  FakeWalletApiService({
    required this.walletsResponse,
    this.transferResponse,
    this.transferError,
  });

  final GetWalletsResponse walletsResponse;
  final TransferResponse? transferResponse;
  final Exception? transferError;

  @override
  Future<GetWalletsResponse> getAllWallets() async => walletsResponse;

  @override
  Future<TransferResponse> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    String? note,
  }) async {
    if (transferError != null) {
      throw transferError!;
    }
    if (transferResponse != null) {
      return transferResponse!;
    }
    throw Exception('No transfer response configured');
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

  test('fetchWallets loads wallets and computes total balance', () async {
    final api = FakeWalletApiService(
      walletsResponse: GetWalletsResponse(
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
    );

    final provider = WalletProvider(apiService: api);

    await provider.fetchWallets(forceRefresh: true);

    expect(provider.wallets.length, 2);
    expect(provider.totalBalance, 390000);
    expect(provider.errorMessage, isEmpty);
  });

  test('transferBetweenWallets updates balances from API response', () async {
    final cashBefore = walletData(
      id: 'cash-id',
      walletType: 'cash',
      balance: 300000,
      name: 'Tiền mặt',
    );
    final bankBefore = walletData(
      id: 'bank-id',
      walletType: 'bank',
      balance: 90000,
      name: 'Ngân hàng',
    );

    final api = FakeWalletApiService(
      walletsResponse: GetWalletsResponse(
        success: true,
        data: [cashBefore, bankBefore],
        totalBalance: 390000,
      ),
      transferResponse: TransferResponse(
        success: true,
        message: 'ok',
        data: TransferData(
          fromWallet: walletData(
            id: 'cash-id',
            walletType: 'cash',
            balance: 280000,
            name: 'Tiền mặt',
          ),
          toWallet: walletData(
            id: 'bank-id',
            walletType: 'bank',
            balance: 110000,
            name: 'Ngân hàng',
          ),
          amount: 20000,
          note: 'move',
        ),
      ),
    );

    final provider = WalletProvider(apiService: api);
    await provider.fetchWallets(forceRefresh: true);

    final success = await provider.transferBetweenWallets(
      fromWalletId: 'cash-id',
      toWalletId: 'bank-id',
      amount: 20000,
      note: 'move',
    );

    expect(success, isTrue);
    expect(provider.getWalletById('cash-id')?.balance, 280000);
    expect(provider.getWalletById('bank-id')?.balance, 110000);
    expect(provider.errorMessage, isEmpty);
  });

  test('transferBetweenWallets returns false and sets error when API fails', () async {
    final api = FakeWalletApiService(
      walletsResponse: GetWalletsResponse(
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
      transferError: Exception('API Error: transfer failed'),
    );

    final provider = WalletProvider(apiService: api);
    await provider.fetchWallets(forceRefresh: true);

    final success = await provider.transferBetweenWallets(
      fromWalletId: 'cash-id',
      toWalletId: 'bank-id',
      amount: 20000,
      note: 'move',
    );

    expect(success, isFalse);
    expect(provider.errorMessage, contains('transfer failed'));
    expect(provider.getWalletById('cash-id')?.balance, 300000);
    expect(provider.getWalletById('bank-id')?.balance, 90000);
  });
}
