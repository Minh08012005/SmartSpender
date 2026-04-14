import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/api_service.dart';
import '../../views/profile/widgets/notification_widgets.dart';

class NotificationsProvider extends ChangeNotifier {
  static NotificationsProvider? _instance;
  static NotificationsProvider? get instance => _instance;

  NotificationsProvider() {
    _instance = this;
    loadNotifications();
  }

  final String _storageKey = 'app_notifications';

  bool isLoading = true;
  List<AppNotification> notifications = [];

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      // Try backend first
      try {
        final api = ApiService();
        final resp = await api.get('/api/notifications');
        final data = resp.data;
        if (data != null && data['data'] is List) {
          final fromBackend = (data['data'] as List)
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
          if (fromBackend.isNotEmpty) {
            // Use backend notifications when available
            notifications = fromBackend;
            await _saveToPrefs();
            isLoading = false;
            notifyListeners();
            return;
          } else {
            // Backend returned empty list — do not overwrite local prefs
            debugPrint('🔔 NotificationsProvider: backend returned empty list, preserving local notifications');
          }
        }
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        notifications = decoded
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        // Debug: report loaded count
        debugPrint('🔔 NotificationsProvider: loaded ${notifications.length} from prefs');
      } else {
        debugPrint('🔔 NotificationsProvider: no stored notifications');
      }
    } catch (_) {
      // ignore
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(notifications.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  Future<void> addLocalNotification(AppNotification n) async {
    notifications.insert(0, n);
    debugPrint('🔔 NotificationsProvider: addLocalNotification ${n.toJson()}');
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifications[idx] = notifications[idx].copyWith(isRead: true);
      notifyListeners();
      _saveToPrefs();
      try {
        await ApiService().patch('/api/notifications/$id/read');
      } catch (_) {}
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    _saveToPrefs();
    try {
      await ApiService().patch('/api/notifications/read-all');
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveToPrefs();
    try {
      await ApiService().delete('/api/notifications/$id');
    } catch (_) {}
  }
}
