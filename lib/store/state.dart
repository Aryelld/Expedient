
import 'package:expedient/models/expedient.dart';

class StoreState{
  List<Expedient> expedients;

  StoreState({ this.expedients=const <Expedient>[] });

  static StoreState fromJson(dynamic json) {
    return json == null ? StoreState(
      expedients: <Expedient>[]
    ) : StoreState(
      expedients: json['expedients'] != null ? json['expedients'].map<Expedient>(
        (expedient) => Expedient.fromJson(expedient)).toList() : null
    );
  }

  StoreState copyWith({ expedients }) => StoreState(
    expedients: expedients ?? this.expedients
  );

  dynamic toJson(){
    return {
      "expedients": expedients.map<dynamic>((expedient) => expedient.toJson()).toList()
    };
  }
}