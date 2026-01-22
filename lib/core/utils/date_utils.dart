class DateUtils {
  static Future<DateTime?> getLastAppVisit() async {
    // TODO: Implement with local storage
    return null;
  }

  static Future<void> saveAppVisit(DateTime date) async {
    // TODO: Implement with local storage
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String getAstrologicalGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Good Morning, Starseeker!';
    } else if (hour < 18) {
      return '☀️ Good Afternoon, Starseeker!';
    } else {
      return '🌙 Good Evening, Starseeker!';
    }
  }
}
