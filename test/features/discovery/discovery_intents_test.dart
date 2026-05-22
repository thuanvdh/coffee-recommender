import 'package:coffee_recommender/features/discovery/domain/discovery_intents.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('presets expose the required discovery ids and intents', () {
    final presets = DiscoveryIntents.presets;
    final presetsById = {
      for (final preset in presets) preset.id: preset,
    };

    expect(
      presetsById.keys,
      unorderedEquals([
        'near_me',
        'work_quiet_aircon',
        'date_night',
        'check_in',
      ]),
    );
    expect(presetsById['near_me']!.intent.nearMe, true);
    expect(presetsById['date_night']!.intent.purposeTags, contains('Hẹn hò'));
    expect(presetsById['check_in']!.intent.purposeTags, contains('Check-in'));
  });

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
