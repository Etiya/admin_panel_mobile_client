import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app_version_update/app_version_update.dart';

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
    db.child("app-version-update").once().then((snapshot) {
      final json = Map<String, dynamic>.from(snapshot.value);
      final AppVersionMetadata appVersion = AppVersionMetadata.fromJson(json);
      setState(() {
        appVersionJson = appVersion.toJson().toString();
      });
      AppVersionPopup.showIfNeeded(appVersion: appVersion, context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appVersionJson,
            ),
          ],
        ),
      ),
    );
  }
}
