import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/services/firestore_service.dart';
import 'package:investify/utils/sizes/size.dart';
import 'package:investify/utils/theme/app_colors.dart';

class AdminKeyInvestorsScreen extends StatefulWidget {
  const AdminKeyInvestorsScreen({super.key});

  @override
  State<AdminKeyInvestorsScreen> createState() =>
      _AdminKeyInvestorsScreenState();
}

class _AdminKeyInvestorsScreenState extends State<AdminKeyInvestorsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _investors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvestors();
  }

  Future<void> _loadInvestors() async {
    setState(() => _isLoading = true);
    try {
      final investors = await _firestoreService.getKeyInvestors();
      setState(() {
        _investors = investors;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading investors: $e');
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load investors');
    }
  }

  Future<void> _deleteInvestor(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Investor'),
        content: const Text(
          'Are you sure you want to delete this investor contact?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteKeyInvestor(id);
        _loadInvestors();
        Get.snackbar('Success', 'Investor deleted');
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete investor');
      }
    }
  }

  void _showInvestorForm({Map<String, dynamic>? existing}) {
    final isEditing = existing != null;
    final institutionCtrl = TextEditingController(
      text: existing?['institutionName'] ?? '',
    );
    final nameCtrl = TextEditingController(
      text: existing?['investorName'] ?? '',
    );
    final designationCtrl = TextEditingController(
      text: existing?['investorDesignation'] ?? '',
    );
    final contactCtrl = TextEditingController(
      text: existing?['contactNumber'] ?? '',
    );
    final emailCtrl = TextEditingController(text: existing?['email'] ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: MySizes.containerPadding,
            right: MySizes.containerPadding,
            top: MySizes.xl,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + MySizes.xl,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: MySizes.xl),
                  Text(
                    isEditing ? 'Edit Investor' : 'Add Investor',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: MySizes.xl),
                  _buildFormField(
                    controller: institutionCtrl,
                    label: 'Institution Name',
                    icon: Icons.business,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: MySizes.medium),
                  _buildFormField(
                    controller: nameCtrl,
                    label: 'Investor Name',
                    icon: Icons.person,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: MySizes.medium),
                  _buildFormField(
                    controller: designationCtrl,
                    label: 'Designation',
                    icon: Icons.badge,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: MySizes.medium),
                  _buildFormField(
                    controller: contactCtrl,
                    label: 'Contact Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: MySizes.medium),
                  _buildFormField(
                    controller: emailCtrl,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: MySizes.xl),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final data = {
                        'institutionName': institutionCtrl.text.trim(),
                        'investorName': nameCtrl.text.trim(),
                        'investorDesignation': designationCtrl.text.trim(),
                        'contactNumber': contactCtrl.text.trim(),
                        'email': emailCtrl.text.trim(),
                      };
                      Navigator.pop(ctx);
                      try {
                        if (isEditing) {
                          await _firestoreService.updateKeyInvestor(
                            existing['id'],
                            data,
                          );
                          Get.snackbar('Success', 'Investor updated');
                        } else {
                          await _firestoreService.addKeyInvestor(data);
                          Get.snackbar('Success', 'Investor added');
                        }
                        _loadInvestors();
                      } catch (e) {
                        debugPrint('Key investor operation error: $e');
                        Get.snackbar('Error', 'Operation failed: $e');
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: MySizes.medium,
                      ),
                    ),
                    child: Text(isEditing ? 'Update' : 'Add'),
                  ),
                  const SizedBox(height: MySizes.medium),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Key Investors'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: MySizes.xxxl),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInvestorForm(),
        backgroundColor: isDark
            ? AppColors.primaryDark
            : AppColors.primaryLight,
        child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _investors.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.contact_phone_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: MySizes.medium),
                  Text(
                    'No investors added yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: MySizes.small),
                  Text(
                    'Tap + to add a key investor contact',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadInvestors,
              child: ListView.builder(
                padding: const EdgeInsets.all(MySizes.containerPadding),
                itemCount: _investors.length,
                itemBuilder: (context, index) {
                  final investor = _investors[index];
                  return _buildInvestorCard(theme, isDark, investor);
                },
              ),
            ),
    );
  }

  Widget _buildInvestorCard(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> investor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: MySizes.medium),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(MySizes.containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight)
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.business,
                    color: isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: MySizes.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor['institutionName'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${investor['investorName'] ?? ''} — ${investor['investorDesignation'] ?? ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showInvestorForm(existing: investor);
                    } else if (value == 'delete') {
                      _deleteInvestor(investor['id']);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: MySizes.medium),
            _buildInfoRow(theme, Icons.phone, investor['contactNumber'] ?? ''),
            const SizedBox(height: MySizes.small),
            _buildInfoRow(theme, Icons.email, investor['email'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: MySizes.small),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
