import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class Schedule {

  TimeOfDay time;
  List<bool> daysOfWeek;

  Schedule({required this.time, required this.daysOfWeek});
}

class MedicationScheduleScreen extends StatefulWidget {
  @override
  _MedicationScheduleScreenState createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  List<Schedule> schedules = [];
  List<String> weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
  FlutterBlue flutterBlue = FlutterBlue.instance;

  BluetoothCharacteristic? _characteristic;

  Future<void> _selectTime(BuildContext context,
      {TimeOfDay? initialTime, int? scheduleIndex}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime ?? TimeOfDay.now(),
        helpText: 'SELECIONE O HORÁRIO',
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        });
    if (pickedTime != null) {
      List<bool> days = scheduleIndex == null
          ? List.generate(7, (_) => false)
          : List.from(schedules[scheduleIndex].daysOfWeek);
      final List<bool>? pickedDays = await showDialog<List<bool>>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(
                      7,
                          (index) => CheckboxListTile(
                        title: Text(weekDays[index]),
                        value: days[index],
                        onChanged: _canToggleDay(index, scheduleIndex)
                            ? (bool? value) {
                          setStateDialog(() {
                            days[index] = value!;
                          });
                        }
                            : null,
                      )),
                  ElevatedButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context, days),
                  )
                ],
              ),
            );
          },
        ),
      );
      if (pickedDays != null) {
        setState(() {
          if (scheduleIndex == null) {
            schedules.add(Schedule(time: pickedTime, daysOfWeek: pickedDays));
          } else {
            schedules[scheduleIndex].time = pickedTime; // Atualizar o horário
            schedules[scheduleIndex].daysOfWeek =
                pickedDays; // Atualizar os dias da semana
          }
        });
      }
    }
  }

  bool _canToggleDay(int day, int? scheduleIndex) {
    for (int i = 0; i < schedules.length; i++) {
      if (i != scheduleIndex && schedules[i].daysOfWeek[day]) {
        return false;
      }
    }
    return true;
  }

  @override
  void _startMedicationTimeCheck() {
    const Duration checkInterval = Duration(seconds: 1);
    Timer.periodic(checkInterval, (_) => _checkMedicationTime());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horários de Medicamentos'),
        actions: [],
      ),
      body: schedules.isEmpty
          ? Center(
          child: Text(
              'Pressione o botão "Adicionar um horário" para adicionar um horário.'))
          : ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) => _buildListTile(context, index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _selectTime(context),
        icon: Icon(Icons.add),
        label: Text('Adicionar um horário'),
        backgroundColor: const Color.fromARGB(255, 159, 33, 243),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _sendDataToArduino(String data) async {
    if (_characteristic != null) {
      await _characteristic!.write(data.codeUnits);
    }
  }

  Future<void> _checkMedicationTime() async {
    final now = TimeOfDay.now();
    TimeOfDay nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

    print('Horário atual: ${now.hour}:${now.minute}');
    for (final schedule in schedules) {
      print(
          'Horário do medicamento: ${schedule.time.hour}:${schedule.time.minute}');

      if (nowTime.hour == schedule.time.hour &&
          nowTime.minute == schedule.time.minute) {
        print('Comparação bem-sucedida! Hora de tomar o medicamento.');
        await _sendDataToArduino("med_time");
        return;
      } else {
        print('Comparação falhou.');
      }
    }
    print('Nenhum horário de medicamento correspondente encontrado.');
  }

  Widget _buildListTile(BuildContext context, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
            "Horário: ${schedules[index].time.format(context)} - Dias: ${_formatDays(schedules[index].daysOfWeek)}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _selectTime(context,
                  initialTime: schedules[index].time, scheduleIndex: index),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteSchedule(index),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDays(List<bool> daysOfWeek) {
    return daysOfWeek
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => weekDays[entry.key])
        .join(', ');
  }

  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }


}