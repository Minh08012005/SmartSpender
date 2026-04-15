import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/group_model.dart';
import '../../data/providers/group_provider.dart';
import '../../theme/colors.dart';

class MembersManagementScreen extends StatefulWidget {
  final GroupModel group;

  const MembersManagementScreen({super.key, required this.group});

  @override
  State<MembersManagementScreen> createState() =>
      _MembersManagementScreenState();
}

class _MembersManagementScreenState extends State<MembersManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Thành Viên'),
        centerTitle: true,
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          final group = groupProvider.selectedGroup ?? widget.group;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${group.members.length} thành viên'),
                  ],
                ),
              ),
              Expanded(
                child: group.members.isEmpty
                    ? const Center(child: Text('Không có thành viên'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: group.members.length,
                        itemBuilder: (ctx, idx) {
                          final member = group.members[idx];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(member.avatar ?? '👤'),
                              ),
                              title: Text(member.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    member.email,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(
                                        member.role,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      member.role.displayName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _getRoleColor(member.role),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: member.isCreator
                                  ? const Icon(Icons.star, color: Colors.orange)
                                  : PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'role') {
                                          _showChangeRole(
                                            context,
                                            group,
                                            member,
                                            groupProvider,
                                          );
                                        } else if (val == 'remove') {
                                          groupProvider.removeMemberFromGroup(
                                            groupId: group.id,
                                            memberId: member.id,
                                          );
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'role',
                                          child: Text('Đổi Quyền'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'remove',
                                          child: Text('Xóa'),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddMember(context, groupProvider),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return Colors.red;
      case MemberRole.member:
        return Colors.blue;
      case MemberRole.viewer:
        return Colors.grey;
    }
  }

  void _showChangeRole(
    BuildContext context,
    GroupModel group,
    GroupMember member,
    GroupProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi Quyền'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: MemberRole.values
              .map(
                (role) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: member.role == role
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                  onPressed: () {
                    if (member.role != role) {
                      provider.updateMemberRole(
                        groupId: group.id,
                        memberId: member.id,
                        newRole: role,
                      );
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(role.displayName),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showAddMember(BuildContext context, GroupProvider provider) {
    final emailController = TextEditingController();
    MemberRole selectedRole = MemberRole.member;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Thêm Thành Viên'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'user@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              DropdownButton<MemberRole>(
                value: selectedRole,
                isExpanded: true,
                items: MemberRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  await provider.addMemberToGroup(
                    groupId: widget.group.id,
                    userEmail: email,
                    role: selectedRole,
                  );
                  if (mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}
