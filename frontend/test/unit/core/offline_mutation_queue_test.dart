import 'package:flutter_test/flutter_test.dart';
import 'package:golden_chicken/core/services/offline_mutation_queue.dart';

void main() {
  group('PendingMutation', () {
    test('serializes and deserializes correctly', () {
      final mutation = PendingMutation(
        id: '123',
        method: 'POST',
        path: '/sheds/shed-1/trends/eggs',
        body: {'totalEggs': 100, 'brokenEggs': 5},
        createdAt: DateTime(2026, 5),
      );

      final json = mutation.toJson();
      final deserialized = PendingMutation.fromJson(json);

      expect(deserialized.id, '123');
      expect(deserialized.method, 'POST');
      expect(deserialized.path, '/sheds/shed-1/trends/eggs');
      expect(deserialized.body['totalEggs'], 100);
      expect(deserialized.createdAt, DateTime(2026, 5));
    });
  });
}
