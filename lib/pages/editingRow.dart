import 'package:expedient/helpers/timeFormatter.dart';
import 'package:expedient/models/expedient.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditingRow extends StatefulWidget {
  final Expedient expedient;
  final Function deleteTime;
  final Function(DateTime) addExpedientAt;
  final Function(Map<int, String>) editExpedientTimes;

  const EditingRow({Key key, this.deleteTime, this.editExpedientTimes, this.addExpedientAt, this.expedient}) : super(key: key);

  @override
  _EditingRowState createState() => _EditingRowState(
    expedient: this.expedient,
    deleteTime: this.deleteTime,
    addExpedientAt: this.addExpedientAt,
    editExpedientTimes: this.editExpedientTimes
  );
}

class _EditingRowState extends State<EditingRow> {
  final Expedient expedient;
  final Function deleteTime;
  final Function(DateTime) addExpedientAt;
  final _formKey = GlobalKey<FormState>();
  final DateFormat format = DateFormat('dd/MM kk:mm');
  final Function(Map<int, String>) editExpedientTimes;

  Map<int, String> editingTimes = {};

  _EditingRowState({this.deleteTime, this.editExpedientTimes, this.addExpedientAt, this.expedient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: this._formKey,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Editando Horários", style: TextStyle(fontSize: 32, color: Theme.of(context).accentColor)),
                      SizedBox(width: 5),
                      Icon(Icons.access_time, size: 32, color: Theme.of(context).accentColor)
                    ],
                  ),
                  Column(
                    children: List.generate(this.expedient.times.length, (index) {
                      return Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextFormField(
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(16),
                            WhitelistingTextInputFormatter(RegExp(r"[0-9:/ ]")),
                            TimeFormatter()
                          ],
                          initialValue: format.format(this.expedient.times[index]),
                          readOnly: false,
                          onChanged: (value){
                            setState(() {
                              this.editingTimes[index] = value;
                            });
                          },
                          validator: (value) {
                            if (value.isEmpty || value.length != 5) {
                              return "Campo vazio ou inválido";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: index % 2 == 0 ? "Pausa" : "Inicio",
                            hintText: "00/00 00:00",
                            suffixIcon: IconButton(
                              icon: Icon(index % 2 != 0 ? Icons.pause : Icons.play_arrow),
                              onPressed: () {
                                this.deleteTime(index);
                              },
                            )
                          ),
                        ),
                      );
                    })
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: (){
                          addExpedientAt(DateTime.now());
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            Text("Novo Ponto", style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)),
                            Icon(Icons.add, color: Theme.of(context).backgroundColor, size: 20)
                          ]
                        ),
                        color: Theme.of(context).accentColor,
                        shape: StadiumBorder()
                      ),
                      RaisedButton( 
                        onPressed: editingTimes.isEmpty ? null : (){
                          editExpedientTimes(editingTimes);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            Text("Salvar", style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 18)),
                            Icon(Icons.save, color: Theme.of(context).backgroundColor, size: 20)
                          ]
                        ),
                        color: Theme.of(context).accentColor,
                        shape: StadiumBorder(),
                      )
                    ],
                  )
                ],
              )
            )
          ),
        )
      )
    );
  }
}