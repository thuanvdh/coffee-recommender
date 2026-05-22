import 'package:coffee_recommender/features/discovery/domain/discovery_intents.dart';
import 'package:coffee_recommender/features/search/domain/models/search_intent.dart';

class DiscoveryController {
  DiscoveryController({
    List<DiscoveryPreset>? presets,
  }) : presets = presets ?? DiscoveryIntents.presets;

  final List<DiscoveryPreset> presets;

  SearchIntent? intentFor(String presetId) {
    for (final preset in presets) {
      if (preset.id == presetId) {
        return preset.intent;
      }
    }
    return null;
  }
}
