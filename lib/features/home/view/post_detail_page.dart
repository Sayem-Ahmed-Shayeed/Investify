import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/home/view/widgets/about_section_widget.dart';
import 'package:investify/features/home/view/widgets/post_detail_appbar.dart';
import 'package:investify/features/home/view/widgets/post_details_company_info.dart';
import 'package:investify/features/home/view/widgets/post_details_financials.dart';
import 'package:investify/features/home/view/widgets/post_details_founders.dart';
import 'package:investify/features/home/view/widgets/post_details_media_gallary.dart';

import '../../../utils/theme/app_colors.dart';
import '../../post_idea/model/post_idea_model.dart';
import '../controller/post_detail_controller.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final post = Get.arguments as PostIdeaModel;
    final controller = Get.put(PostDetailController(post));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : AppColors.scaffoldBackgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            PostDetailAppBar(controller: controller),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.media.isNotEmpty)
                      PostDetailMediaGallery(controller: controller),
                    PostDetailCompanyInfo(controller: controller),
                    const PostDetailFinancials(),
                    PostDetailAbout(controller: controller),
                    PostDetailFounders(controller: controller),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
