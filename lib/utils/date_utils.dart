import 'package:intl/intl.dart';

class DateUtils {
  static String formatPolishDate(DateTime date) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'pl_PL');
    return formatter.format(date);
  }

  static String formatShortDate(DateTime date) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(date);
  }

  static String getTimeUntilDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      final daysPast = difference.inDays.abs();
      if (daysPast == 0) {
        return 'Przeterminowane dziś';
      } else if (daysPast == 1) {
        return 'Przeterminowane wczoraj';
      } else {
        return 'Przeterminowane $daysPast dni temu';
      }
    }
    
    final days = difference.inDays;
    final hours = difference.inHours;
    
    if (days == 0) {
      if (hours == 0) {
        return 'Za kilka minut';
      } else if (hours == 1) {
        return 'Za godzinę';
      } else {
        return 'Za $hours godzin';
      }
    } else if (days == 1) {
      return 'Jutro';
    } else {
      return 'Za $days dni';
    }
  }

  static String getDayOfWeek(DateTime date) {
    final dayNames = [
      'Niedziela', 'Poniedziałek', 'Wtorek', 'Środa', 
      'Czwartek', 'Piątek', 'Sobota'
    ];
    
    return dayNames[date.weekday % 7];
  }
}
