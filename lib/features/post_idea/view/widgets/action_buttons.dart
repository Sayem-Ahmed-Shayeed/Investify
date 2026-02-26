import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/utils/sizes/size.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onPublish;
  final bool isPublishing;
  final bool isSavingDraft;
  final String? uploadStatus;

  const ActionButtons({
    super.key,
    required this.onPublish,
    this.isPublishing = false,
    this.isSavingDraft = false,
    this.uploadStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final isLoading = isPublishing || isSavingDraft;

    return Container(
      padding: const EdgeInsets.all(MySizes.containerPadding),
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upload status indicator
            if (uploadStatus != null && uploadStatus!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: MySizes.small),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      uploadStatus!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            // Buttons row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onPublish,
                    icon: isPublishing
                        ? const SizedBox(
                            width: MySizes.iconSmall,
                            height: MySizes.iconSmall,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: MySizes.iconMedium),
                    label: Text(
                      isPublishing ? 'Publishing...' : 'Publish Post',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: MySizes.large,
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MySizes.roundedButtonCorner,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
