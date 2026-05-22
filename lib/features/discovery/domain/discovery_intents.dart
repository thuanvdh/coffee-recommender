import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class DiscoveryPreset {
  DiscoveryPreset({
    required this.id,
    required this.label,
    required this.intent,
  });

  final String id;
  final String label;
  final SearchIntent intent;
}

class DiscoveryIntents {
  DiscoveryIntents._();

  static List<DiscoveryPreset> get presets => [
        DiscoveryPreset(
          id: 'near_me',
          label: 'Gần tôi',
          intent: SearchIntent(nearMe: true),
        ),
        DiscoveryPreset(
          id: 'work_quiet_aircon',
          label: 'Làm việc yên tĩnh',
          intent: SearchIntent(
            purposeTags: ['Làm việc'],
            spaceTags: ['Yên tĩnh'],
            amenityTags: ['Máy lạnh'],
          ),
        ),
        DiscoveryPreset(
          id: 'date_night',
          label: 'Hẹn hò',
          intent: SearchIntent(purposeTags: ['Hẹn hò']),
        ),
        DiscoveryPreset(
          id: 'check_in',
          label: 'Check-in',
          intent: SearchIntent(purposeTags: ['Check-in']),
        ),
      ];
}
