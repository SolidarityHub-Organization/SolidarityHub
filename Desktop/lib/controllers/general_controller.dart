class GeneralController {
  static DateTime adjustEndDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
