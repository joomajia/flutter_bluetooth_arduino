import 'package:bluet_app/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:bluet_app/SelecionarDispositivo.dart';
import 'package:provider/provider.dart';
import 'provider/StatusConexaoProvider.dart';


// void main() => runApp(MyAppik());


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<StatusConexaoProvider>.value(
              value: StatusConexaoProvider()),
        ],
        child: MaterialApp(
          title: 'dfgdfgfd',
          initialRoute: '/',
          routes: {
            '/': (context) => const HomePage(),
            '/selectDevice': (context) => const SelecionarDispositivoPage(),
          },
        ));
  }
}
