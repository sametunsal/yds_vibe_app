import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _activityKey = 'study_activity';

  // Save today's activity
  static Future<void> saveStudyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activity = prefs.getStringList(_activityKey) ?? [];
    final today = _getTodayFormatted();

    if (!activity.contains(today)) {
      activity.add(today);
      await prefs.setStringList(_activityKey, activity);
    }
  }

  // Calculate current streak
  static Future<int> getStreakCount() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activity = prefs.getStringList(_activityKey) ?? [];

    if (activity.isEmpty) return 0;

    // Sort dates descending
    activity.sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayStr = _getTodayFormatted();

    // Check if studied today
    bool studiedToday = activity.contains(todayStr);

    // If studied today, start count from today. If not, start from yesterday.
    DateTime checkDate = studiedToday
        ? today
        : today.subtract(const Duration(days: 1));

    while (true) {
      final checkDateStr = _formatDate(checkDate);
      if (activity.contains(checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Get activity for the last 7 days (including today)
  // Returns a list of booleans where index 0 is 6 days ago, index 6 is today
  static Future<List<bool>> getLast7DaysActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activity = prefs.getStringList(_activityKey) ?? [];
    final List<bool> last7Days = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      last7Days.add(activity.contains(dateStr));
    }

    return last7Days;
  }

  static String _getTodayFormatted() {
    return _formatDate(DateTime.now());
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
