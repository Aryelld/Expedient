
import 'package:expedient/models/expedient.dart';
import 'package:expedient/store/actions.dart';
import 'package:expedient/store/state.dart';
import 'package:intl/intl.dart';
import 'dart:math';

final _random = new Random();
int next(int min, int max) => min + _random.nextInt(max - min);

Duration calculatePauseTime(Expedient expedient){
  List<DateTime> pauseTimes = expedient.times.sublist(1);
  List<List<DateTime>> pauseRow = pauseTimes.fold<List<List<DateTime>>>([<DateTime>[]], (List<List<DateTime>> previousValue, DateTime element) {
    if(previousValue.last.length < 2) {
      List<DateTime> nextList = previousValue.removeAt(previousValue.length-1);
      nextList.add(element);
      previousValue.add(nextList);
    } else {
      List<DateTime> nextList = [
        element
      ];
      previousValue.add(nextList);
    }
    return previousValue;
  });
  return pauseRow.fold(Duration(), (acc, curr) {
    Duration duration = curr.length > 0 ? curr.last.difference(curr.first) : Duration();
    return acc + duration;
  });
}

StoreState reduce(StoreState state, dynamic action){
  if (action is UpdateDateTime) {
    List<Expedient> expedients = state.expedients;
    if(expedients.isNotEmpty) {
      if(expedients.last.times.first.day == action.dateTime.day) {
        List<DateTime> expedientTimes = expedients.last.times;
        expedientTimes.add(action.dateTime);
        Expedient expedient = expedients.last.copyWith(
          times: expedientTimes
        );
        expedients.removeAt(expedients.length-1);
        expedients.add(expedient);
        return state.copyWith(expedients: expedients);
      }
    }
    expedients.add(Expedient(times: [ action.dateTime ]));
    return state.copyWith(expedients: expedients);
  } else if (action is DeleteDateTime) {
    List<Expedient> expedients = state.expedients;
    Expedient expedient = expedients.removeAt(action.expedientIndex);
    expedient.times = expedient.times.sublist(0, action.timeIndex);
    if(expedient.times.length > 0) expedients.insert(action.expedientIndex, expedient); 
    return state.copyWith(expedients: expedients);
  } else if (action is AddDateTimeAt) {
    List<Expedient> expedients = state.expedients;
    Expedient expedient = expedients.removeAt(action.expedientIndex);
    expedient.times.add(action.dateTime);
    expedients.insert(action.expedientIndex, expedient); 
    return state.copyWith(expedients: expedients);
  } else if (action is EditExpedientTimes) {
    DateFormat format = DateFormat('dd/MM kk:mm');
    List<Expedient> expedients = state.expedients;
    Expedient expedient = expedients.removeAt(action.expedientIndex);
    DateTime currentTime = DateTime.now();
    action.editingTimes.forEach((int index, String dateString) { 
      expedient.times.removeAt(index);
      DateTime time = format.parse(dateString).add(Duration(hours: 1));
      expedient.times.insert(index, DateTime(currentTime.year, time.month, time.day, time.hour, time.minute)); 
    });
    expedients.insert(action.expedientIndex, expedient);
    return state.copyWith(expedients: expedients);
  } else if (action is CorrectHours) {
    List<Expedient> expedients = state.expedients;
    List<Expedient> correctedExpedients = [];
    expedients.forEach((Expedient expedient) {
      List<DateTime> times = expedient.times;
      List<DateTime> correctTimes = [];
      if(times.first.hour > 12) {
        correctTimes.add(times.first.subtract(Duration(hours: 1)));
      } else {
        correctTimes.add(times.first);
      }
      correctTimes.add(correctTimes.first.add(Duration(minutes: next(180, 300))));
      correctTimes.add(correctTimes.last.add(Duration(hours: 1)));
      Duration duration = calculatePauseTime(expedient);
      if(times.length > 1) {
        if(times.first.hour > 12) {
          correctTimes.add(times.last.subtract(duration));
        } else {
          correctTimes.add(times.last.add(Duration(hours: 1)).subtract(duration));
        }
      }
      Expedient newExpedient = expedient.copyWith(times: correctTimes);
      correctedExpedients.add(newExpedient);
    });
    return state.copyWith(expedients: correctedExpedients);
  }
  return state;
}