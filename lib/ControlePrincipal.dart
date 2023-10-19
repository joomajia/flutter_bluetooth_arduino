// ignore_for_file: file_names
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'components/VoiceButtonPage.dart';

class ControlePrincipalPage extends StatefulWidget {
  final BluetoothDevice? server;
  const ControlePrincipalPage({super.key, this.server});

  @override
  _ControlePrincipalPage createState() => _ControlePrincipalPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ControlePrincipalPage extends State<ControlePrincipalPage> {
  static const clientID = 0;
  BluetoothConnection? connection;
  String? language;

  // ignore: deprecated_member_use
  List<_Message> messages = <_Message>[];
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;
  bool buttonClicado = false;
  double speed = 1;
  double bbb = 0;
  String? command;
  final List<String> _languages = ['en_US'];

  bool isMoving = false;

  String message = "";

  double myDoubleValue = 0.5; // Ваше число double

  void sendCommand() {
    if (connection != null) {
      String dataToSend = speed.toString();
      connection!.output.add(Uint8List.fromList(speed.toString().codeUnits));
      connection!.output.allSent.then((_) {
        print('$speed');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }
  }

  void sendData(int data) {
    if (connection != null) {
      connection!.output.add(Uint8List.fromList([data]));
      connection?.output.allSent.then((_) {
        setState(() {
          message = "Отправлено: $data";
        });
      });
    }
  }

  void sendChar(String char) {
    if (connection != null) {
      connection?.output.add(Uint8List.fromList(char.codeUnits));
      connection!.output.allSent.then((_) {
        setState(() {
          message = "Отправлено: $char";
        });
      });
    }
  }

  void moveForward() {
    // Отправить команду на движение вперед на Arduino (по аналогии с предыдущими ответами).
    if (connection != null && connection!.isConnected) {
      connection!.output
          .add(Uint8List.fromList('F'.codeUnits)); // Движение вперед
    }
  }

  void moveStop() {
    // Отправить команду на остановку на Arduino (по аналогии с предыдущими ответами).
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList('S'.codeUnits));
    }
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

// ...

// ...

  @override
  void initState() {
    super.initState();
    _initSpeech();
    BluetoothConnection.toAddress(widget.server!.address).then((connection) {
      print('Connected to device');
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnected localy!');
        } else {
          print('Disconnected remote!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Failed to connect, something is wrong!');
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    messages.map((message) {
      return Row(
        mainAxisAlignment: message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(message.text.trim()),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Column(children: [
                          SizedBox(
                              height: 60, width: 90, child: SizedBox.shrink())
                        ]),
                        const SizedBox(width: 30),
                        Column(children: [
                          SizedBox(
                            height: 60,
                            width: 90,
                            child: VoiceButtonComponent(
                                connection: connection,
                                clientID: clientID,
                                languageSelected: language),
                          ),
                        ]),
                        const SizedBox(width: 30),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                child: DropdownButton<String>(
                                  value: language ?? 'en_US',
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: _languages.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  // After selecting the desired option,it will
                                  // change button value to selected value
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      language = newValue!;
                                    });
                                  },
                                ),
                              )
                            ]),
                      ]),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      // If listening is active show the recognized words
                      _speechToText.isListening
                          ? _lastWords
                          // If listening isn't active but could be tell the user
                          // how to start it, otherwise indicate that speech
                          // recognition is not yet ready or not supported on
                          // the target device
                          : _speechEnabled
                              ? 'Tap the microphone to start listening...'
                              : 'Speech not available',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                onLongPressStart: (details) {
                                  setState(() {
                                    isMoving = true;
                                    moveForward(); // Начать движение вперед
                                  });
                                },
                                onLongPressEnd: (details) {
                                  setState(() {
                                    isMoving = false;
                                    moveStop(); // Остановить движение
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: isMoving ? Colors.green : Colors.red,
                                  child: Center(
                                    child: Text(
                                        isMoving ? 'Движение' : 'Остановлено'),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          ElevatedButton(
                            onPressed: () {
                              sendData(bbb
                                  .round()); // Отправка символа 'A' на Arduino
                            },
                            child: const Text('Отправить символ на Arduino'),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              sendChar(
                                  "ddd"); // Отправка символа 'A' на Arduino
                            },
                            child: const Text('Отправить символ на Arduino'),
                          ),

                          Slider(
                            value: speed,
                            onChanged: (value) {
                              setState(() {
                                speed = value;
                                bbb = speed * 255;
                                print(bbb);
                                sendChar(bbb.toString());
                                // sendData(bbb.round());
                              });
                            },
                          ),

                          FloatingActionButton(
                            onPressed:
                                // If not yet listening for speech start, otherwise stop
                                _speechToText.isNotListening
                                    ? _startListening
                                    : _stopListening,
                            tooltip: 'Listen',
                            child: Icon(_speechToText.isNotListening
                                ? Icons.mic_off
                                : Icons.mic),
                          ),

                          Text(message),
                          ElevatedButton(
                            onPressed: () {
                              sendData(
                                  bbb.round()); // Отправка числа 42 на Arduino
                            },
                            child: const Text('Скорость'),
                          ),

                          // ElevatedButton(
                          //   onPressed: () {
                          //     sendData(100); // Отправка числа 42 на Arduino
                          //   },
                          //   child: Text('сотка'),
                          // ),

                          // ElevatedButton(
                          //   onPressed: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'F'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   onLongPress: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'F'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   child: Text('Вперед'),
                          // ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output
                          //           .add(Uint8List.fromList('L'.codeUnits));
                          //     }
                          //   },
                          //   onLongPress: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output
                          //           .add(Uint8List.fromList('L'.codeUnits));
                          //     }
                          //   },
                          //   child: Text('Лево'),
                          // ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'R'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   onLongPress: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'R'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   child: Text('Право'),
                          // ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'B'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   onLongPress: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'B'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   child: Text('Назад'),
                          // ),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     if (connection != null &&
                          //         connection!.isConnected) {
                          //       connection!.output.add(Uint8List.fromList(
                          //           'S'.codeUnits)); // Движение вперед
                          //     }
                          //   },
                          //   child: Text('STOP'),
                          // ),

                          ElevatedButton(
                            onPressed: () {
                              if (connection != null &&
                                  connection!.isConnected) {
                                connection!.output.add(Uint8List.fromList(
                                    1.toString().codeUnits)); // Движение вперед
                              }
                            },
                            child: const Text('J'),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              if (connection != null &&
                                  connection!.isConnected) {
                                connection!.output.add(Uint8List.fromList(0.5
                                    .toString()
                                    .codeUnits)); // Движение вперед
                              }
                            },
                            child: const Text('K'),
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: <Widget>[
                          //     Text('Speed: ${speed.toStringAsFixed(2)}'),
                          //     Slider(
                          //       value: speed,
                          //       onChanged: (value) {
                          //         setState(() {
                          //           speed = value;
                          //           connection!.output.add(Uint8List.fromList(
                          //               speed.toString().codeUnits));
                          //           connection!.output.allSent.then((_) {
                          //             print('$speed');
                          //           });

                          //         });
                          //       },
                          //     ),
                          //   ],
                          // ),
                        ]),
                        const SizedBox(width: 30),
                      ]),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 20),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Column(children: [
                //           ButtonDoubleComponent(
                //             buttonName: "R",
                //             comandOn: '1',
                //             comandOff: '0',
                //             clientID: clientID,
                //             connection: connection,
                //           ),
                //         ]),
                //       ]),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}











// Метод для подключения к Arduino

// void connectToDevice() async {
//   List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
//   for (BluetoothDevice device in devices) {
//     if (device.name == "Имя вашего Arduino") {
//       try {
//         connection = await BluetoothConnection.toAddress(device.address);
//       } catch (error) {
//         print(error);
//       }
//       break;
//     }
//   }
// }

// Метод для отправки данных на Arduino


