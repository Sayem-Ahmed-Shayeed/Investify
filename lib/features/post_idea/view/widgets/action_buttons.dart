import 'package:flutter/material.dart';
import 'package:investify/utils/sizes/size.dart';

/// Bottom action bar with Save Draft and Publish Post buttons
class ActionButtons extends StatelessWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;
  final bool isPublishing;
  final bool isSavingDraft;

  const ActionButtons({
    super.key,
    required this.onSaveDraft,
    required this.onPublish,
    this.isPublishing = false,
    this.isSavingDraft = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(RomRomSizes.containerPadding),
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Save Draft Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSavingDraft || isPublishing ? null : onSaveDraft,
                icon: isSavingDraft
                    ? SizedBox(
                        width: RomRomSizes.iconSmall,
                        height: RomRomSizes.iconSmall,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onSurface,
                        ),
                      )
                    : const Icon(
                        Icons.save_outlined,
                        size: RomRomSizes.iconMedium,
                      ),
                label: Text(isSavingDraft ? 'Saving...' : 'Save Draft'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: RomRomSizes.large,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      RomRomSizes.roundedButtonCorner,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: RomRomSizes.roundedBoxCorner),
            // Publish Post Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isPublishing || isSavingDraft ? null : onPublish,
                icon: isPublishing
                    ? const SizedBox(
                        width: RomRomSizes.iconSmall,
                        height: RomRomSizes.iconSmall,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: RomRomSizes.iconMedium),
                label: Text(isPublishing ? 'Publishing...' : 'Publish Post'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: RomRomSizes.large,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      RomRomSizes.roundedButtonCorner,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
