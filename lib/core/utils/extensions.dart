import 'package:intl/intl.dart';

extension StringIsoTime on String {
  String fromIsoTime() {
    DateTime dateTime = DateTime.parse(this);

    DateTime localTime = dateTime.toLocal();

    String formattedTime = DateFormat('hh:mm a').format(localTime);

    // استبدال AM → ص ، PM → م
    formattedTime = formattedTime.replaceAll("AM", "ص").replaceAll("PM", "م");
    return formattedTime;
  }
}
