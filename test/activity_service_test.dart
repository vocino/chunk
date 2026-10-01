import 'package:flutter_test/flutter_test.dart';
import 'package:chunk/models/break_activity.dart';
import 'package:chunk/services/activity_service.dart';

List<BreakActivity> _makeActivities(int count) => List.generate(
      count,
      (i) => BreakActivity(
        id: 'act-$i',
        text: 'Activity $i',
        emoji: '🎉',
        category: 'test',
      ),
    );

void main() {
  group('ActivityService — anti-repeat selection', () {
    test('getRandomActivity never returns a recently used activity', () {
      final activities = _makeActivities(5);
      final service = ActivityService(activities: activities);

      // Mark the first 4 as recent; only the 5th should ever be returned.
      final recentIds = activities.take(4).map((a) => a.id).toList();

      for (var i = 0; i < 20; i++) {
        final picked = service.getRandomActivity(recentIds);
        expect(recentIds.contains(picked.id), isFalse,
            reason: 'should not pick a recently used activity');
      }
    });

    test('getRandomActivity falls back to full pool when all activities are recent', () {
      final activities = _makeActivities(3);
      final service = ActivityService(activities: activities);

      // All activities are recent — the pool resets and still returns something.
      final allIds = activities.map((a) => a.id).toList();
      final picked = service.getRandomActivity(allIds);

      expect(activities.any((a) => a.id == picked.id), isTrue);
    });

    test('getRandomActivity throws when activities have not been loaded', () {
      final service = ActivityService(); // empty pool — loadActivities never called
      expect(() => service.getRandomActivity([]), throwsException);
    });
  });
}
