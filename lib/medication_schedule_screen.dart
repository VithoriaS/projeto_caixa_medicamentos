import 'package:flutter/material.dart';

class Schedule {
  TimeOfDay time;
  List<bool> daysOfWeek;

  Schedule({required this.time, required this.daysOfWeek});
}

class MedicationScheduleScreen extends StatefulWidget {
  @override
  _MedicationScheduleScreenState createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  List<Schedule> schedules = [];
  List<String> weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  Future<void> _selectTime(BuildContext context, {TimeOfDay? initialTime, int? scheduleIndex}) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: 'SELECIONE O HORÁRIO',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      }
    );
    if (pickedTime != null) {
      List<bool> days = scheduleIndex == null ? List.generate(7, (_) => false) : List.from(schedules[scheduleIndex].daysOfWeek);
      final List<bool>? pickedDays = await showDialog<List<bool>>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(7, (index) => CheckboxListTile(
                    title: Text(weekDays[index]),
                    value: days[index],
                    onChanged: _canToggleDay(index, scheduleIndex) ? (bool? value) {
                      setStateDialog(() {
                        days[index] = value!;
                      });
                    } : null,
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
            schedules[scheduleIndex].daysOfWeek = pickedDays; // Atualizar os dias da semana
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

  Widget _buildListTile(BuildContext context, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text("Horário: ${schedules[index].time.format(context)} - Dias: ${_formatDays(schedules[index].daysOfWeek)}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _selectTime(context, initialTime: schedules[index].time, scheduleIndex: index),
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
    return daysOfWeek.asMap().entries.where((entry) => entry.value).map((entry) => weekDays[entry.key]).join(', ');
  }

  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horários de Medicamentos'),
      ),
      body: schedules.isEmpty
          ? Center(child: Text('Pressione o botão "Adicionar um horário" para adicionar um horário.'))
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) => _buildListTile(context, index),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _selectTime(context),
        icon: Icon(Icons.add),
        label: Text('Adicionar um horário'),
        backgroundColor: Color.fromARGB(255, 194, 145, 227),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
