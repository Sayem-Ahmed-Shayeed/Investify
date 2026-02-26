import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/services/firestore_service.dart';
import 'package:investify/utils/sizes/size.dart';

class UserDetailPage extends StatefulWidget {
  final String uid;

  const UserDetailPage({super.key, required this.uid});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _firestoreService.getUserByUid(widget.uid);
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load user data');
    }
  }

  Future<void> _approveUser() async {
    try {
      await _firestoreService.approveUser(widget.uid);
      setState(() {
        _userData = {..._userData!, 'isVerified': true};
      });
      Get.snackbar('Success', 'User approved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve user');
    }
  }

  Future<void> _rejectUser() async {
    try {
      await _firestoreService.rejectUser(widget.uid);
      setState(() {
        _userData = {..._userData!, 'isVerified': false};
      });
      Get.snackbar('Success', 'User rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject user');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isVerified = _userData?['isVerified'] ?? false;
    final isAdmin = _userData?['isAdmin'] ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text('User not found'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(RomRomSizes.containerPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          backgroundImage:
                              _userData?['profileImageUrl'] != null &&
                                  _userData!['profileImageUrl'].isNotEmpty
                              ? CachedNetworkImageProvider(
                                  _userData!['profileImageUrl'],
                                )
                              : null,
                          child:
                              _userData?['profileImageUrl'] == null ||
                                  _userData!['profileImageUrl'].isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(height: RomRomSizes.medium),

                        // Name
                        Text(
                          _userData?['name'] ?? 'Unknown',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: RomRomSizes.small),

                        // Email
                        Text(
                          _userData?['email'] ?? 'No email',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: RomRomSizes.medium),

                        // Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            RomRomSizes.containerPadding,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                'Age',
                                '${_userData?['age'] ?? 'N/A'}',
                              ),

                              const Divider(),
                              _buildDetailRow(
                                'Status',
                                isAdmin ? 'Admin' : 'User',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: RomRomSizes.large),

                        // NID Card Section
                        Text(
                          'NID Card',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: RomRomSizes.small),
                        if (_userData?['nidCardUrl'] != null &&
                            _userData!['nidCardUrl'].isNotEmpty)
                          GestureDetector(
                            onTap: () =>
                                _openNidFullscreen(_userData!['nidCardUrl']),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: _userData!['nidCardUrl'],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'No NID card uploaded',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        const SizedBox(height: RomRomSizes.small),
                        Text(
                          'Tap to view full size',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons (only for non-admin users)
                if (!isAdmin)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        RomRomSizes.containerPadding,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isVerified ? null : _approveUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: RomRomSizes.medium),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isVerified ? _rejectUser : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _openNidFullscreen(String imageUrl) {
    Get.to(() => NidFullscreenPage(imageUrl: imageUrl));
  }
}

class NidFullscreenPage extends StatelessWidget {
  final String imageUrl;

  const NidFullscreenPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('NID Card'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
