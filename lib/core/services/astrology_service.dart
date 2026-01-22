import '../models/user_model.dart';

class TimeWindow {
  final DateTime startTime;
  final DateTime endTime;
  final String bestTime;
  final String planet;
  final int durationInMinutes;

  TimeWindow({
    required this.startTime,
    required this.endTime,
    this.bestTime = '3:00 PM - 5:00 PM',
    this.planet = 'Jupiter',
    this.durationInMinutes = 120,
  });

  @override
  String toString() => '${startTime.hour}:00 - ${endTime.hour}:00';
}

class DailyInsight {
  final String message;
  final String tip;

  DailyInsight({
    required this.message,
    required this.tip,
  });
}

class AstrologyService {
  static TimeWindow calculateLuckyTimeWindow(UserProfile user) {
    final now = DateTime.now();
    final startHour = (now.hour + 3) % 24;
    final endHour = (startHour + 2) % 24;

    return TimeWindow(
      startTime: DateTime(now.year, now.month, now.day, startHour),
      endTime: DateTime(now.year, now.month, now.day, endHour),
    );
  }

  static DailyInsight generateDailyInsight(UserProfile user) {
    final insights = [
      ('✨ The stars align in your favor today. Trust your intuition.', 'Meditate in the morning for clarity'),
      ('🌟 A new opportunity approaches. Be ready to seize it.', 'Stay open to new possibilities'),
      ('💫 Your cosmic energy is at its peak. Use it wisely.', 'Channel your energy into positive actions'),
      ('🔮 The universe guides you toward success today.', 'Follow your instincts'),
      ('⭐ Your lucky period begins. Make the most of it.', 'Take decisive action now'),
    ];

    final index = DateTime.now().day % insights.length;
    final (message, tip) = insights[index];
    return DailyInsight(message: message, tip: tip);
  }
}
