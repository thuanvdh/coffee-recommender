import 'package:coffee_recommender/features/discovery/domain/discovery_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work_quiet_aircon preset maps to work, quiet space and aircon intent',
      () {
    final preset = DiscoveryIntents.presets.singleWhere(
      (preset) => preset.id == 'work_quiet_aircon',
    );

    expect(preset.label, 'Làm việc yên tĩnh');
    expect(preset.intent.purposeTags, ['Làm việc']);
    expect(preset.intent.spaceTags, ['Yên tĩnh']);
    expect(preset.intent.amenityTags, ['Máy lạnh']);
  });
}
