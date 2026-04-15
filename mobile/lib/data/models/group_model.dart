import 'package:flutter/material.dart';

/// Enum cho các role trong group
enum MemberRole {
  admin('Admin', 'Quản lý nhóm, thêm/xóa thành viên'),
  member('Thành viên', 'Tạo giao dịch, xem chi tiết'),
  viewer('Xem', 'Chỉ xem dữ liệu, không tạo giao dịch');

  final String displayName;
  final String description;

  const MemberRole(this.displayName, this.description);

  String toJson() => name;

  static MemberRole fromJson(String value) {
    return MemberRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemberRole.member,
    );
  }
}

/// Model cho Member trong Group
class GroupMember {
  final String id; // user id
  final String name;
  final String email;
  final String? avatar;
  final MemberRole role;
  final DateTime joinedAt;
  final bool isCreator;

  GroupMember({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    required this.joinedAt,
    this.isCreator = false,
  });

  // Factory từ API response
  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String? ?? json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      role: MemberRole.fromJson(json['role'] as String? ?? 'member'),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
      isCreator: json['isCreator'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'role': role.toJson(),
    'joinedAt': joinedAt.toIso8601String(),
    'isCreator': isCreator,
  };

  // Copy with
  GroupMember copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    MemberRole? role,
    DateTime? joinedAt,
    bool? isCreator,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isCreator: isCreator ?? this.isCreator,
    );
  }

  @override
  String toString() => 'GroupMember($name, $role)';
}

/// Model cho Group
class GroupModel {
  final String id; // MongoDB ObjectId
  final String name;
  final String? description;
  final String createdBy; // user id
  final List<GroupMember> members;
  final double totalBalance; // Tổng tiền trong group
  final int totalTransactions; // Số giao dịch
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.members,
    this.totalBalance = 0,
    this.totalTransactions = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory từ API response
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final membersData = json['members'] as List<dynamic>? ?? [];
    final members = membersData
        .cast<Map<String, dynamic>>()
        .map((m) => GroupMember.fromJson(m))
        .toList();

    return GroupModel(
      id: json['id'] as String? ?? json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String,
      members: members,
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    '_id': id,
    'name': name,
    'description': description,
    'createdBy': createdBy,
    'members': members.map((m) => m.toJson()).toList(),
    'totalBalance': totalBalance,
    'totalTransactions': totalTransactions,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Copy with
  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<GroupMember>? members,
    double? totalBalance,
    int? totalTransactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      totalBalance: totalBalance ?? this.totalBalance,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Group($name, ${members.length} members)';
}
