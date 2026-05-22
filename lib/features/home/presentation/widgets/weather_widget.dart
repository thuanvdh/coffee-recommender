import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_recommender/core/theme/app_colors.dart';

class WeatherWidget extends StatelessWidget {
  final double temperature;
  final int weatherCode;
  final VoidCallback onTap;

  const WeatherWidget({
    super.key,
    required this.temperature,
    required this.weatherCode,
    required this.onTap,
  });

  String _getWeatherDesc() {
    if (weatherCode >= 51 && weatherCode <= 67) {
      return 'Trời đang mưa 🌧️ - Tìm quán có mái che nhé!';
    } else if (temperature > 30.0) {
      return 'Trời khá oi nóng ☀️ - Trốn nắng ở phòng máy lạnh thôi!';
    } else {
      return 'Thời tiết rất đẹp ⛅ - Lên sân thượng ngắm phố nào!';
    }
  }

  IconData _getWeatherIcon() {
    if (weatherCode >= 51 && weatherCode <= 67) {
      return LucideIcons.cloud_rain;
    } else if (weatherCode >= 1 && weatherCode <= 3) {
      return LucideIcons.cloud;
    } else {
      return LucideIcons.sun;
    }
  }

  Color _getWeatherIconColor(bool isDark) {
    if (weatherCode >= 51 && weatherCode <= 67) {
      return isDark ? AppColors.darkSkyline : AppColors.lightSkyline;
    } else if (weatherCode >= 1 && weatherCode <= 3) {
      return isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
    } else {
      return isDark ? AppColors.darkAccent : AppColors.lightAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardBgColor = isDark ? AppColors.darkBgLight : AppColors.lightBgLight;
    final iconColor = _getWeatherIconColor(isDark);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBgColor.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getWeatherIcon(), color: iconColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Đà Nẵng hôm nay',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextLight : AppColors.lightTextLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getWeatherDesc(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.arrow_right,
                  size: 14,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

