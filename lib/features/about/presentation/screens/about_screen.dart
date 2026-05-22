import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:coffee_recommender/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final textLightColor = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final cardBgColor = isDark ? AppColors.darkBgLight : AppColors.lightBgLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final sectionBgColor = isDark ? AppColors.darkBgSection : AppColors.lightBgSection;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giới thiệu'),
      ),
      body: ListView(
        children: [
          // Section 1: Hero
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Về Danang Coffee',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dự án cộng đồng nhằm tôn vinh và chia sẻ những giá trị văn hóa cà phê độc đáo tại thành phố Đà Nẵng.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: textLightColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Section 2: Mission Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sứ mệnh của chúng mình',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Đà Nẵng không chỉ có biển và núi, mà còn là nơi hội tụ của hàng trăm quán cà phê với đủ mọi phong cách từ hoài cổ, hiện đại đến những góc nhỏ ẩn mình.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textLightColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chúng mình tạo ra Danang Coffee để giúp bạn dễ dàng tìm thấy "quán ruột" của mình, dù bạn cần không gian để làm việc hiệu quả hay một góc chill cùng bạn bè.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textLightColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Why Choose Us
          Container(
            color: sectionBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            child: Column(
              children: [
                Text(
                  'Tại sao chọn Danang Coffee?',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                                const _FeatureCard(
                  icon: LucideIcons.square_check,
                  title: 'Thông tin chính xác',
                  description: 'Dữ liệu được cập nhật thường xuyên về giờ mở cửa, giá cả và tiện ích.',
                ),
                const SizedBox(height: 16),
                const _FeatureCard(
                  icon: LucideIcons.sliders_horizontal,
                  title: 'Tìm kiếm thông minh',
                  description: 'Bộ lọc đa dạng giúp bạn tìm quán theo mục đích sử dụng và phong cách không gian.',
                ),
                const SizedBox(height: 16),
                const _FeatureCard(
                  icon: LucideIcons.users,
                  title: 'Cộng đồng đóng góp',
                  description: 'Mọi người đều có thể gửi đề xuất quán mới để làm phong phú thêm cẩm nang.',
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                '© 2026 Danang Coffee. Crafted with ❤️.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textLightColor.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textLightColor = isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final cardBgColor = isDark ? AppColors.darkBgLight : AppColors.lightBgLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: textLightColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

