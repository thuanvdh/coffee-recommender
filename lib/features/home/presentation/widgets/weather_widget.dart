import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final double temperature;
  final int weatherCode;

  const WeatherWidget({
    super.key,
    required this.temperature,
    required this.weatherCode,
  });

  String _getRecommendation() {
    if (temperature >= 30.0) {
      return 'Trời nóng → Hãy chọn quán có Máy Lạnh để mát mẻ!';
    } else if (temperature <= 24.0) {
      return 'Trời mát mẻ → Các quán Ngoài Trời sẽ rất tuyệt!';
    } else {
      return 'Thời tiết đẹp → Lý tưởng để đi bất kỳ đâu!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getRecommendation(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
