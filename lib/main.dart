import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:maintenance_mode/maintenance_mode.dart';

late FirebaseApp app;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String appVersionJson = "";
  final DatabaseReference db = FirebaseDatabase(app: app).reference();

  @override
  void initState() {
    super.initState();
    db.child("appVersionUpdate").once().then(
      (snapshot) {
        final json = Map<String, dynamic>.from(snapshot.value);
        final AppVersionMetadata appVersion = AppVersionMetadata.fromJson(json);
        appVersionJson = appVersion.toJson().toString();
        debugPrint(appVersionJson);
        AppVersionPopup.showIfNeeded(appVersion: appVersion, context: context);
      },
    );
    db.child("maintenanceMode").onValue.map((event) => event.snapshot).forEach(
      (snapshot) {
        final json = Map<String, dynamic>.from(snapshot.value);
        final MaintenanceMode maintenanceMode = MaintenanceMode.fromJson(json);
        debugPrint(maintenanceMode.toJson().toString());
        MaintenanceModeManager.shared
            .showIfNeeded(maintenanceMode: maintenanceMode, context: context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            title: Text(
              "Supported Features",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const ListTile(
            title: Text("* App Version Update"),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
          const ListTile(
            title: Text("* Maintenance Mode"),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
          const Spacer(flex: 1),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Image(
              image: AssetImage("assets/images/logo_etiya.png"),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
