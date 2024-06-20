import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _connection;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  void _connectToDevice(String address) async {
    try {
      _connection = await BluetoothConnection.toAddress(address);
      setState(() {
        _isConnected = true;
      });
      print('Connected to the device');

      _connection!.input!.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
      }).onDone(() {
        print('Disconnected by remote request');
        setState(() {
          _isConnected = false;
        });
      });
    } catch (e) {
      print('Cannot connect, exception occurred: $e');
    }
  }

  void _disconnectFromDevice() async {
    await _connection?.close();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Bluetooth Serial Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Bluetooth State: $_bluetoothState'),
            SizedBox(height: 20),
            _isConnected
                ? ElevatedButton(
                    onPressed: _disconnectFromDevice,
                    child: Text('Disconnect'),
                  )
                : ElevatedButton(
                    onPressed: () => _connectToDevice('XX:XX:XX:XX:XX:XX'), // Substitua pelo endereÃ§o do seu dispositivo
                    child: Text('Connect'),
                  ),
          ],
        ),
      ),
    );
  }
}