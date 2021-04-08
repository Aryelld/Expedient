import 'package:expedient/home.dart';
import 'package:expedient/store/actions.dart';
import 'package:expedient/store/reducers.dart';
import 'package:expedient/store/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:redux_persist/redux_persist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final persistor = Persistor<StoreState>(
    storage: FlutterStorage(),
    serializer: JsonSerializer<StoreState>(StoreState.fromJson),
  );

  final initialState = await persistor.load();
  final store = new Store<StoreState>(
    reduce, initialState: initialState.copyWith(),
    middleware: [persistor.createMiddleware()]
  );
  runApp(Phoenix(child: MyApp(store: store)));
}

class MyApp extends StatelessWidget {
  final Store<StoreState> store;

  const MyApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return StoreProvider<StoreState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "ProductSans",
          backgroundColor: Colors.white,
          accentColor: Colors.redAccent
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: "ProductSans",
          backgroundColor: Color(0xFF2b2b2b),
          accentColor: Colors.redAccent
        ),
        home: StoreConnector<StoreState, Map<String, dynamic>>(
          builder: (context, resource) => MyHomePage(
            expedients: resource["expedients"],
            addExpedient: resource["addExpedient"],
            correctHours: resource["correctHours"]
          ),
          converter: (store) => {
            "expedients": store.state.expedients,
            "addExpedient": (DateTime dateTime) => store.dispatch(UpdateDateTime(dateTime: dateTime)),
            "correctHours": () => store.dispatch(CorrectHours())
          }
        )
      )
    );
  }
}