import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/subjects.dart';

class mainRegras implements BlocBase {

  var timerShow = BehaviorSubject<String>();
  Stream<String> get gettimerShow => timerShow.stream;

  void refreshTimer() {
    Future.delayed(new Duration(seconds: 1), () {
      var time = getTimeString();
      timerShow.add(time);
    });
  }

  DateTime timeExpired;

  void setTimeExpired() {
    var duration = new Duration(minutes: 3);
    timeExpired = DateTime.now().add(duration);
  }

  String getTimeString() {
    var horaAtual = DateTime.now();
    var timeDiff = timeExpired.difference(horaAtual);
    var inHours = timeDiff.inHours;
    var inMinutes = timeDiff.inMinutes - (inHours * 60);
    var inSeconds = timeDiff.inSeconds - (timeDiff.inMinutes * 60);

    if (timeDiff.inSeconds < 0) {
      return "00:00";
    }

    var hour = "";
    var minute = "";
    var second = "";
    if (inHours > 0) {
      if (inHours < 10) {
        hour += "0";
      }
      hour += inHours.toString() + ":";
    }

    if (inMinutes < 10) {
      minute += "0";
    }
    minute += inMinutes.toString() + ":";

    if (inSeconds < 10) {
      second += "0";
    }
    second += inSeconds.toString();

    var time = hour + minute + second;
    return time;
  }

  @override
  void addListener(listener) {}

  @override
  void dispose() {}

  @override
  bool get hasListeners => throw UnimplementedError();

  @override
  void notifyListeners() {}

  @override
  void removeListener(listener) {}
}
