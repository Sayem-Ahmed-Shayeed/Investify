import 'package:url_launcher/url_launcher.dart';

String getDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selected = DateTime(date.year, date.month, date.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  if (selected == today) return 'Today';
  if (selected == tomorrow) return 'Tomorrow';
  if (selected == yesterday) return 'Yesterday';

  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return days[date.weekday - 1];
}

String formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

Future<void> launchPhone(String number) async {
  final uri = Uri.parse('tel:$number');
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {}
}

Future<void> launchEmail(String email) async {
  final uri = Uri.parse('mailto:$email');
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {}
}
