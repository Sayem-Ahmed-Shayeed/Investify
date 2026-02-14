import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../utils/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Container(
      color: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading Video...',
              style: TextStyle(
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
