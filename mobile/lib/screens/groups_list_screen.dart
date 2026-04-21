import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/group_provider.dart';
import '../../theme/colors.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhóm Của Tôi'), centerTitle: true),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          if (groupProvider.isLoading && groupProvider.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupProvider.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Không có nhóm nào'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateGroup(context, groupProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo Nhóm'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groupProvider.groups.length + 1,
            itemBuilder: (ctx, idx) {
              if (idx == groupProvider.groups.length) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreateGroup(ctx, groupProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Tạo Nhóm Mới'),
                  ),
                );
              }
              final group = groupProvider.groups[idx];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(group.name),
                  subtitle: Text('${group.members.length} thành viên'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'dashboard') {
                        groupProvider.selectGroup(group.id);
                        Navigator.pushNamed(
                          context,
                          '/group-dashboard',
                          arguments: group,
                        );
                      } else if (val == 'members') {
                        groupProvider.selectGroup(group.id);
                        Navigator.pushNamed(
                          context,
                          '/members-management',
                          arguments: group,
                        );
                      } else if (val == 'delete') {
                        groupProvider.deleteGroup(group.id);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'dashboard',
                        child: Text('Xem Dashboard'),
                      ),
                      const PopupMenuItem(
                        value: 'members',
                        child: Text('Quản Lý Thành Viên'),
                      ),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                    ],
                  ),
                  onTap: () {
                    groupProvider.selectGroup(group.id);
                    Navigator.pushNamed(
                      context,
                      '/group-dashboard',
                      arguments: group,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<GroupProvider>(
        builder: (context, groupProvider, _) {
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showCreateGroup(context, groupProvider),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _showCreateGroup(BuildContext context, GroupProvider provider) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Nhóm Mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên nhóm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await provider.createGroup(name: name, description: '');
                if (!context.mounted) return;
                Navigator.of(context).pop();
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}
