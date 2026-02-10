import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/break_activity.dart';

class ActivityService {
  List<BreakActivity> _activities = [];
  final Random _random = Random();

  Future<void> loadActivities() async {
    final String jsonString = await rootBundle.loadString('assets/data/activities.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _activities = jsonList.map((json) => BreakActivity.fromJson(json as Map<String, dynamic>)).toList();
  }

  BreakActivity getRandomActivity(List<String> recentIds) {
    if (_activities.isEmpty) {
      throw Exception('Activities not loaded');
    }

    // Filter out recent activities
    List<BreakActivity> availableActivities = _activities
        .where((activity) => !recentIds.contains(activity.id))
        .toList();

    // If all activities have been used recently, reset the pool
    if (availableActivities.isEmpty) {
      availableActivities = _activities;
    }

    // Return random activity
    return availableActivities[_random.nextInt(availableActivities.length)];
  }
}
