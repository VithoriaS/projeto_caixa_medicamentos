import 'package:flutter/material.dart';
import 'medication_schedule_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caixa de Medicamentos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Color.fromARGB(255, 168, 107, 179), // Cor de fundo da AppBar
          titleTextStyle: TextStyle(
            color: Colors.white, // Cor do texto
            fontSize: 20, // Tamanho da fonte
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MedicationScheduleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
