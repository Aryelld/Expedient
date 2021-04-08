class UpdateDateTime {
  DateTime dateTime;
  UpdateDateTime({this.dateTime});
}

class DeleteDateTime {
  int expedientIndex;
  int timeIndex;
  DeleteDateTime({this.expedientIndex, this.timeIndex});
}

class AddDateTimeAt {
  DateTime dateTime;
  int expedientIndex;
  AddDateTimeAt({this.dateTime, this.expedientIndex});
}

class EditExpedientTimes {
  int expedientIndex;
  Map<int, String> editingTimes;
  EditExpedientTimes({this.editingTimes, this.expedientIndex});
}

class CorrectHours {
  CorrectHours();
}