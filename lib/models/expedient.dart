
class Expedient{
  List<DateTime> times;

  Expedient({ this.times });

  static Expedient fromJson(dynamic json) {
    return Expedient(
      times: json['times'] != null ? List.generate(json['times'].length, (index) => 
        DateTime.fromMillisecondsSinceEpoch(json['times'][index])) : null
    );
  }

  Expedient copyWith({times}) => Expedient(
    times: times ?? this.times
  );

  dynamic toJson(){
    return {
      "times": this.times != null ? List.generate(this.times.length, (index) => 
        this.times[index].millisecondsSinceEpoch) : null
    };
  }
}