class DateHelper {
  DateHelper();
  static String formatForEpicor(DateTime date){
    return '${date.month}-${date.day}-${date.year}';
  }
}