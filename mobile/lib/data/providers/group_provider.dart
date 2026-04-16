import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/group_model.dart';
import '../dummy_groups.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

/// Group Provider
/// Quản lý state của groups và members
/// Sử dụng ChangeNotifier để notify UI khi data thay đổi
class GroupProvider extends ChangeNotifier {
  // ============== PRIVATE STATE ==============
  List<GroupModel> _groups = [];
  GroupModel? _selectedGroup;
  bool _isLoading = false;
  String _error = '';

  // API Service instance
  late final ApiService _apiService;

  // Use mock data by default (for testing before API ready)
  bool useMockData = true;

  GroupProvider({
    ApiService? apiService,
    List<GroupModel>? initialGroups,
    bool useMock = true,
  }) {
    _apiService = apiService ?? ApiService();
    useMockData = useMock;

    // Initialize with mock data if no initial groups provided
    if (initialGroups != null) {
      _groups = initialGroups;
    } else if (useMockData) {
      _groups = List.from(dummyGroups);
    }
  }

  // ============== GETTERS ==============
  List<GroupModel> get groups => _groups;
  GroupModel? get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;
  int get groupsCount => _groups.length;
  double get totalGroupBalance =>
      _groups.fold(0.0, (sum, g) => sum + g.totalBalance);

  // ============== PRIVATE METHODS ==============
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  // ============== PUBLIC METHODS ==============

  /// Lấy danh sách groups từ API (hoặc mock data nếu chưa ready)
  Future<void> fetchGroups() async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 800));
        _groups = List.from(dummyGroups);
      } else {
        // Real API call (khi backend ready)
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final response = await _apiService.dio
            .get('${ApiConstants.baseUrl}/api/groups', options: options)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = response.data as List<dynamic>;
          _groups = data
              .cast<Map<String, dynamic>>()
              .map((g) => GroupModel.fromJson(g))
              .toList();
        }
      }
      _setLoading(false);
    } catch (e) {
      _setError('Lỗi khi lấy danh sách nhóm: $e');
      _setLoading(false);
      debugPrint('❌ GroupProvider.fetchGroups() error: $e');
    }
  }

  /// Lấy chi tiết group (kể cả members)
  Future<void> fetchGroupDetail(String groupId) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        _selectedGroup = _groups.firstWhere(
          (g) => g.id == groupId,
          orElse: () => _groups[0],
        );
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final response = await _apiService.dio
            .get(
              '${ApiConstants.baseUrl}/api/groups/$groupId',
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _selectedGroup = GroupModel.fromJson(response.data);
        }
      }
      _setLoading(false);
    } catch (e) {
      _setError('Lỗi khi lấy chi tiết nhóm: $e');
      _setLoading(false);
      debugPrint('❌ GroupProvider.fetchGroupDetail() error: $e');
    }
  }

  /// Tạo group mới
  Future<bool> createGroup({
    required String name,
    required String description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 600));

        final newGroup = GroupModel(
          id: 'group_${_groups.length + 1}',
          name: name,
          description: description,
          createdBy: 'user_001', // Mock user
          members: [
            GroupMember(
              id: 'user_001',
              name: 'Mai Huy Minh',
              email: 'minh@smartspender.com',
              role: MemberRole.admin,
              joinedAt: DateTime.now(),
              isCreator: true,
            ),
          ],
          totalBalance: 0,
          totalTransactions: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        _groups.add(newGroup);
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final payload = {'name': name, 'description': description};

        final response = await _apiService.dio
            .post(
              '${ApiConstants.baseUrl}/api/groups',
              data: payload,
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          final newGroup = GroupModel.fromJson(response.data);
          _groups.add(newGroup);
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Lỗi khi tạo nhóm: $e');
      _setLoading(false);
      debugPrint('❌ GroupProvider.createGroup() error: $e');
      return false;
    }
  }

  /// Cập nhật group
  Future<bool> updateGroup({
    required String groupId,
    required String name,
    String? description,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));

        final index = _groups.indexWhere((g) => g.id == groupId);
        if (index != -1) {
          _groups[index] = _groups[index].copyWith(
            name: name,
            description: description,
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final payload = {
          'name': name,
          if (description != null) 'description': description,
        };

        final response = await _apiService.dio
            .patch(
              '${ApiConstants.baseUrl}/api/groups/$groupId',
              data: payload,
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final index = _groups.indexWhere((g) => g.id == groupId);
          if (index != -1) {
            _groups[index] = GroupModel.fromJson(response.data);
          }
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Lỗi khi cập nhật nhóm: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Xóa group
  Future<bool> deleteGroup(String groupId) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        _groups.removeWhere((g) => g.id == groupId);
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final response = await _apiService.dio
            .delete(
              '${ApiConstants.baseUrl}/api/groups/$groupId',
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _groups.removeWhere((g) => g.id == groupId);
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Lỗi khi xóa nhóm: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Thêm member vào group
  Future<bool> addMemberToGroup({
    required String groupId,
    required String userEmail,
    required MemberRole role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));

        final groupIndex = _groups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) {
          final group = _groups[groupIndex];
          final newMember = GroupMember(
            id: 'user_${group.members.length + 1}',
            name: userEmail.split('@')[0],
            email: userEmail,
            role: role,
            joinedAt: DateTime.now(),
          );
          group.members.add(newMember);
          _groups[groupIndex] = group.copyWith(
            members: [...group.members],
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final payload = {'email': userEmail, 'role': role.name};

        final response = await _apiService.dio
            .post(
              '${ApiConstants.baseUrl}/api/groups/$groupId/members',
              data: payload,
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201) {
          // Refresh group detail
          await fetchGroupDetail(groupId);
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Lỗi khi thêm thành viên: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Cập nhật role của member
  Future<bool> updateMemberRole({
    required String groupId,
    required String memberId,
    required MemberRole newRole,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));

        final groupIndex = _groups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) {
          final group = _groups[groupIndex];
          final memberIndex = group.members.indexWhere((m) => m.id == memberId);
          if (memberIndex != -1) {
            group.members[memberIndex] = group.members[memberIndex].copyWith(
              role: newRole,
            );
            _groups[groupIndex] = group.copyWith(
              members: [...group.members],
              updatedAt: DateTime.now(),
            );
          }
        }
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final payload = {'role': newRole.name};

        final response = await _apiService.dio
            .patch(
              '${ApiConstants.baseUrl}/api/groups/$groupId/members/$memberId',
              data: payload,
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          // Refresh group detail
          await fetchGroupDetail(groupId);
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Lỗi khi cập nhật quyền: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Xóa member khỏi group
  Future<bool> removeMemberFromGroup({
    required String groupId,
    required String memberId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (useMockData) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));

        final groupIndex = _groups.indexWhere((g) => g.id == groupId);
        if (groupIndex != -1) {
          final group = _groups[groupIndex];
          group.members.removeWhere((m) => m.id == memberId);
          _groups[groupIndex] = group.copyWith(
            members: [...group.members],
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Real API call
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

        final options = token.isNotEmpty
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null;

        final response = await _apiService.dio
            .delete(
              '${ApiConstants.baseUrl}/api/groups/$groupId/members/$memberId',
              options: options,
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          // Refresh group detail
          await fetchGroupDetail(groupId);
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Lỗi khi xóa thành viên: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Chọn group để xem/edit
  void selectGroup(String groupId) {
    _selectedGroup = _groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => _groups.isEmpty
          ? GroupModel(
              id: '',
              name: '',
              createdBy: '',
              members: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          : _groups[0],
    );
    notifyListeners();
  }

  /// Clear selected group
  void clearSelection() {
    _selectedGroup = null;
    notifyListeners();
  }
}
