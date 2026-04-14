import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/strings.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';
import '../../data/providers/notifications_provider.dart';
import 'widgets/notification_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Notification settings
  bool _inAppNotifications = true;
  bool _emailNotifications = true;
  bool _transactionNotifications = true;
  bool _securityAlerts = true;
  bool _budgetAlerts = true;
  bool _reminderNotifications = true;
  bool _promotionNotifications = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotificationSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationsProvider>(context, listen: false)
          .loadNotifications();
    });
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _inAppNotifications = prefs.getBool('inAppNotifications') ?? true;
        _emailNotifications = prefs.getBool('emailNotifications') ?? true;
        _transactionNotifications =
            prefs.getBool('transactionNotifications') ?? true;
        _securityAlerts = prefs.getBool('securityAlerts') ?? true;
        _budgetAlerts = prefs.getBool('budgetAlerts') ?? true;
        _reminderNotifications = prefs.getBool('reminderNotifications') ?? true;
        _promotionNotifications =
            prefs.getBool('promotionNotifications') ?? false;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveNotificationSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('inAppNotifications', _inAppNotifications),
        prefs.setBool('emailNotifications', _emailNotifications),
        prefs.setBool('transactionNotifications', _transactionNotifications),
        prefs.setBool('securityAlerts', _securityAlerts),
        prefs.setBool('budgetAlerts', _budgetAlerts),
        prefs.setBool('reminderNotifications', _reminderNotifications),
        prefs.setBool('promotionNotifications', _promotionNotifications),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.notificationsPreferencesSaved),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.notificationsPreferencesFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _markAsRead(String notificationId) {
    Provider.of<NotificationsProvider>(
      context,
      listen: false,
    ).markAsRead(notificationId);
  }

  void _markAllAsRead() {
    Provider.of<NotificationsProvider>(context, listen: false).markAllAsRead();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo đã đọc'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    Provider.of<NotificationsProvider>(
      context,
      listen: false,
    ).deleteNotification(notificationId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa thông báo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool get _hasUnreadNotifications {
    final provider = Provider.of<NotificationsProvider>(context);
    return provider.notifications.any((n) => !n.isRead);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h trước';
    } else {
      return '${difference.inDays}d trước';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.notificationsTitle,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Trung tâm thông báo'),
            Tab(text: 'Tùy chỉnh'),
          ],
        ),
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationCenter(provider),
                  _buildPreferencesTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildNotificationCenter(NotificationsProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_hasUnreadNotifications)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _markAllAsRead,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.notificationsMarkAllAsRead,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          if (provider.notifications.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.notificationsNoNotifications,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return _buildNotificationItem(notification, index);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SectionReveal(
        delayMs: 50 * index,
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade300
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _markAsRead(notification.id),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _getNotificationIcon(notification.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatTime(notification.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _markAsRead(notification.id),
                        child: const Text('Đánh dấu đã đọc'),
                      ),
                      PopupMenuItem(
                        onTap: () => _deleteNotification(notification.id),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'transaction':
        icon = Icons.swap_horiz_outlined;
        color = Colors.blue;
        break;
      case 'security':
        icon = Icons.security_outlined;
        color = Colors.red;
        break;
      case 'budget':
        icon = Icons.trending_up_outlined;
        color = Colors.orange;
        break;
      case 'promotion':
        icon = Icons.local_offer_outlined;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications_outlined;
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            SectionReveal(
              delayMs: 0,
              child: NotificationPreferenceCard(
                icon: Icons.notifications_outlined,
                title: AppStrings.notificationsInAppNotifications,
                value: _inAppNotifications,
                onChanged: (value) {
                  setState(() {
                    _inAppNotifications = value;
                  });
                },
              ),
            ),

            SectionReveal(
              delayMs: 50,
              child: NotificationPreferenceCard(
                icon: Icons.mail_outline,
                title: AppStrings.notificationsEmailNotifications,
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Loại thông báo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            SectionReveal(
              delayMs: 100,
              child: NotificationPreferenceCard(
                icon: Icons.swap_horiz_outlined,
                title: AppStrings.notificationsTransactions,
                subtitle: AppStrings.notificationsTransactionsDesc,
                value: _transactionNotifications,
                onChanged: (value) {
                  setState(() {
                    _transactionNotifications = value;
                  });
                },
              ),
            ),

            SectionReveal(
              delayMs: 150,
              child: NotificationPreferenceCard(
                icon: Icons.security_outlined,
                title: AppStrings.notificationsSecurityAlerts,
                subtitle: AppStrings.notificationsSecurityAlertsDesc,
                value: _securityAlerts,
                onChanged: (value) {
                  setState(() {
                    _securityAlerts = value;
                  });
                },
              ),
            ),

            SectionReveal(
              delayMs: 200,
              child: NotificationPreferenceCard(
                icon: Icons.trending_up_outlined,
                title: AppStrings.notificationsBudgetAlerts,
                subtitle: AppStrings.notificationsBudgetAlertsDesc,
                value: _budgetAlerts,
                onChanged: (value) {
                  setState(() {
                    _budgetAlerts = value;
                  });
                },
              ),
            ),

            SectionReveal(
              delayMs: 250,
              child: NotificationPreferenceCard(
                icon: Icons.alarm_outlined,
                title: AppStrings.notificationsReminders,
                subtitle: AppStrings.notificationsRemindersDesc,
                value: _reminderNotifications,
                onChanged: (value) {
                  setState(() {
                    _reminderNotifications = value;
                  });
                },
              ),
            ),

            SectionReveal(
              delayMs: 300,
              child: NotificationPreferenceCard(
                icon: Icons.local_offer_outlined,
                title: AppStrings.notificationsPromotions,
                subtitle: AppStrings.notificationsPromotionsDesc,
                value: _promotionNotifications,
                onChanged: (value) {
                  setState(() {
                    _promotionNotifications = value;
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveNotificationSettings,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          AppStrings.notificationsSavePreferences,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
