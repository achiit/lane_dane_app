class NotificationTimeScheduler {
  void scheduleForMidnight() {
    var now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 0, 0, 0);
    var difference = scheduledTime.difference(now);
    if (difference.inSeconds < 0) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
      difference = scheduledTime.difference(now);
    }
  }
}
