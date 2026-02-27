import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/admin/view/admin_key_investors_screen.dart';
import 'package:investify/features/admin/view/user_detail_page.dart';
import 'package:investify/services/firestore_service.dart';
import 'package:investify/utils/sizes/size.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _firestoreService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading users: $e');
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load users: $e');
    }
  }

  Future<void> _approveUser(String uid) async {
    try {
      await _firestoreService.approveUser(uid);
      _loadData();
      Get.snackbar('Success', 'User approved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve user');
    }
  }

  Future<void> _rejectUser(String uid) async {
    try {
      await _firestoreService.rejectUser(uid);
      _loadData();
      Get.snackbar('Success', 'User rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject user');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_phone_outlined),
            tooltip: 'Manage Key Investors',
            onPressed: () =>
                Get.to(() => const AdminKeyInvestorsScreen()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _buildUsersTab(theme),
    );
  }

  Widget _buildUsersTab(ThemeData theme) {
    if (_users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(MySizes.containerPadding),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isVerified = user['isVerified'] ?? false;
          final isAdmin = user['isAdmin'] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: MySizes.medium),
            child: ListTile(
              onTap: () => Get.to(() => UserDetailPage(uid: user['uid'])),
              title: Text(user['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? 'No email'),
                  Row(
                    children: [
                      if (isAdmin)
                        Container(
                          margin: const EdgeInsets.only(top: 4, right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      if (isVerified)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Approved',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      if (!isVerified && !isAdmin)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              trailing: !isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isVerified)
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                            ),
                            onPressed: () => _approveUser(user['uid']),
                            tooltip: 'Approve',
                          ),
                        if (isVerified)
                          IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red.shade600,
                            ),
                            onPressed: () => _rejectUser(user['uid']),
                            tooltip: 'Reject',
                          ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
