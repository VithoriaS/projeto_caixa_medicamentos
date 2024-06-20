import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _requestPermissions();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  void _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _connectToDevice(String address) async {
    var status = await Permission.bluetoothScan.status;
    if (!status.isGranted) {
      await Permission.bluetoothScan.request();
    }
    status = await Permission.bluetoothConnect.status;
    if (!status.isGranted) {
      await Permission.bluetoothConnect.request();
    }
    status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }

    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
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
    } else {
      print('Required permissions not granted');
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
                    onPressed: () => _connectToDevice(
                        '00:23:04:00:01:56'), // Substitua pelo endereço do seu dispositivo
                    child: Text('Connect'),
                  ),
          ],
        ),
      ),
    );
  }
}
