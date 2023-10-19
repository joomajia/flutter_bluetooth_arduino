// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bluet_app/SelecionarDispositivo.dart';
import 'package:bluet_app/ControlePrincipal.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'components/CustomAppBar.dart';
import 'provider/StatusConexaoProvider.dart';

FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
BluetoothConnection? connection;

// Сопряжение с Bluetooth-устройствами
Future<void> connectToBluetoothDevice(BluetoothDevice device) async {
  connection = await BluetoothConnection.toAddress(device.address);
  print('Connected to ${device.name}');

  // Прослушивание данных от Arduino
  connection!.input!.listen((Uint8List data) {
    String message = String.fromCharCodes(data);
    print('Received: $message');
    // Здесь можно обработать полученные данные
  });

  // Отправка данных на Arduino
  connection?.output.add(Uint8List.fromList('Hello Arduino'.codeUnits));
  await connection?.output.allSent;
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onPressBluetooth() {
      return (() async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings: const RouteSettings(name: 'selectDevice'),
            builder: (context) => const SelecionarDispositivoPage()));
      });
    }

    return Scaffold(
      appBar: CustomAppBar(
        Title: 'Remote Arduino',
        isBluetooth: true,
        isDiscovering: false,
        onPress: onPressBluetooth,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Consumer<StatusConexaoProvider>(
              builder: (context, StatusConnectionProvider, widget) {
            return (StatusConnectionProvider.device == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (connection != null && connection!.isConnected) {
                            connection?.output.add(Uint8List.fromList('1'.codeUnits)); // Включить светодиод на Arduino
                          }
                        },
                        child: Text('Включить светодиод'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (connection != null && connection!.isConnected) {
                            connection!.output.add(Uint8List.fromList('0'
                                .codeUnits)); // Выключить светодиод на Arduino
                          }
                        },
                        child: Text('Выключить светодиод'),
                      ),
                      const Icon(Icons.bluetooth_disabled_sharp, size: 50),
                      const Text(
                        "Bluetooth Disconnected",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    ],
                  )
                : ControlePrincipalPage(
                    server: StatusConnectionProvider.device));
          }),
        ),
      ),
    );
  }
}
