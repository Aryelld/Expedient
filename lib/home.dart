
import 'package:expedient/models/expedient.dart';
import 'package:expedient/pages/editingRow.dart';
import 'package:expedient/store/actions.dart';
import 'package:expedient/store/state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  final List<Expedient> expedients;
  final Function(DateTime) addExpedient;
  final Function() correctHours;
  
  const MyHomePage({ Key key, @required this.expedients, @required this.addExpedient, this.correctHours }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(expedients: this.expedients, correctHours: this.correctHours, addExpedient: this.addExpedient);
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Expedient> expedients;
  final Function(DateTime) addExpedient;
  final Function() correctHours;
  final DateFormat formatDate = DateFormat('dd/MM');
  final DateFormat formatHour = DateFormat('kk:mm');

  _MyHomePageState({this.expedients, this.addExpedient, this.correctHours});
  
  List<List<DateTime>> _getRows(Expedient expedient){
    return expedient.times.fold<List<List<DateTime>>>([<DateTime>[]], (List<List<DateTime>> previousValue, DateTime element) {
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
  }

  Widget _buildExpedient(Expedient expedient, int index) {
    List<List<DateTime>> rows = _getRows(expedient);
    return Card(
      margin: EdgeInsets.only(top: 20),
      elevation: 5,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Text("Expediente do dia ${formatDate.format(expedient.times.first)}", style: TextStyle(fontSize: 23)),
              DataTable(
                dividerThickness: 0,
                showCheckboxColumn: false,
                columns: [
                  DataColumn(
                    label: Row(
                    children: <Widget>[
                      Text("Trabalho", style: TextStyle(color: Colors.grey)),
                      Icon(Icons.play_arrow, color: Colors.grey)
                    ]
                  )),
                  DataColumn(
                    label: Row(
                    children: <Widget>[
                      Text("Pausa", style: TextStyle(color: Colors.grey)),
                      Icon(Icons.pause, color: Colors.grey)
                    ]
                  ))
                ], 
                rows: List.generate(rows.length, (index) => DataRow(
                  cells: [
                    DataCell(
                      Text(formatHour.format(rows[index].first))
                    ),
                    DataCell(
                      Text(rows[index].length > 1 ? formatHour.format(rows[index].last) : "Hora?")
                    ),
                  ])
                )
              ),
              SizedBox(height: 20),
              Text("Total do dia: ${_calculateHours(rows)}")
            ]
          )
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoreConnector<StoreState, Map<String, Function>>(
                builder: (context, resources) => EditingRow(
                  expedient: expedient, 
                  deleteTime: resources['deleteTime'],
                  addExpedientAt: resources['addExpedientAt'],
                  editExpedientTimes: resources['editExpedientTimes']
                ),
                converter: (store) => {
                  'addExpedientAt': (DateTime dateTime) {
                    store.dispatch(AddDateTimeAt(expedientIndex: index, dateTime: dateTime));
                  },
                  'editExpedientTimes': (Map<int, String> editingTimes) {
                    store.dispatch(EditExpedientTimes(expedientIndex: index, editingTimes: editingTimes));
                    Navigator.of(context).pop();
                    Phoenix.rebirth(context);
                  },
                  'deleteTime': (int timeIndex) {
                    store.dispatch(DeleteDateTime(expedientIndex: index, timeIndex: timeIndex));
                    if(expedient.times.length == 0) {
                      Navigator.of(context).pop();
                      Phoenix.rebirth(context);
                    }
                  }
                }
              )
            )
          );
        },
      ),
    );
  } 

  _calculateHours(List<List<DateTime>> rows, {bool isInHours = false}){
    Duration duration = rows.fold<Duration>(Duration(), (Duration previousValue, List<DateTime> pieceOfExpedient) {
      DateTime endDateTime = pieceOfExpedient.length > 1 ? pieceOfExpedient.last : DateTime.now();
      Duration pieceOfDuration = endDateTime.difference(pieceOfExpedient.first);
      return previousValue + pieceOfDuration;
    });
    int allMinutes = duration.inMinutes;
    if(isInHours) return allMinutes/60;
    int hour = (allMinutes/60).floor();
    int minutes = allMinutes - hour*60;
    String minuteString = minutes >= 10 ? "$minutes" : "0$minutes";
    String hourString = hour >= 10 ? "$hour" : "0$hour";
    return "$hourString:$minuteString";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,                  
                      children: <Widget>[
                        Text("Meu Expediente", style: TextStyle(fontSize: 32, color: Theme.of(context).accentColor)),
                        SizedBox(width: 5),
                        Icon(Icons.work, size: 32, color: Theme.of(context).accentColor)
                      ],
                    ),
                    expedients.length > 0 ? Container(
                      margin: EdgeInsets.only(top: 20),
                      height: 100, width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: BorderRadius.all(Radius.circular(20))
                      ),
                      child: BezierChart(
                        bezierChartScale: BezierChartScale.CUSTOM,
                        xAxisCustomValues: List.generate(expedients.length, (index) => double.parse('$index.0')),
                        series: [
                          BezierLine(
                            data: List.generate(expedients.length, (index) {
                              return DataPoint<double>(value: _calculateHours(_getRows(expedients[index]), isInHours: true), xAxis: double.parse('$index.0'));
                            })
                          ),
                        ],
                        config: BezierChartConfig(
                          verticalIndicatorStrokeWidth: 3.0,
                          verticalIndicatorColor: Colors.black26,
                          showVerticalIndicator: true,
                          snap: false,
                        ),
                      ),
                    ) : SizedBox(),
                  ] + List.generate(this.expedients.length, (index) => _buildExpedient(this.expedients[index], index)).reversed.toList()
                )
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(right: 15, bottom: 90),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "1",
                backgroundColor: Theme.of(context).backgroundColor,
                onPressed: () {
                  correctHours();
                  Phoenix.rebirth(context);
                },
                child: Icon(Icons.refresh, color: Theme.of(context).textTheme.bodyText1.color),
              )
            )
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                heroTag: "2",
                onPressed: () {
                  addExpedient(DateTime.now());
                  Phoenix.rebirth(context);
                },
                child: Icon(Icons.control_point),
              )
            )
          )
        ],
      )
    );
  }
}