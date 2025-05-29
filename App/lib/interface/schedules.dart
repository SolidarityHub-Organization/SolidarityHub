import 'package:app/services/register_flow_manager.dart';
import 'package:flutter/material.dart';
import '/controllers/schedulesController.dart';
import '/models/user_registration_data.dart';
import 'registerChoose.dart';

class Schedules extends StatefulWidget {
  final RegisterFlowManager manager;
  Schedules({required this.manager});

  @override
  _SchedulesState createState() => _SchedulesState();
}

class _SchedulesState extends State<Schedules> {

  @override
  void initState() {
    super.initState();
    final selected = widget.manager.userData.schedule?.split(', ') ?? [];
    controller.selectedTimes.addAll(selected);
  }

  final SchedulesController controller = SchedulesController();

  final Map<String, String> timeLabels = {
    '🌞 Mañana': '(8:00 - 11:00)',
    '🌤️ Mediodía': '(11:00 - 14:00)',
    '🌥️ Tarde': '(16:00 - 19:00)',
    '🌙 Noche': '(19:00 - 22:00)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              widget.manager.saveStep();
              widget.manager.restorePreviousStep();
              Navigator.pop(context);
            },
          ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: 4 / 6, // Paso 2 de 6
              backgroundColor: Colors.red[100],
              color: Colors.white,
              minHeight: 4,
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.red,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 100),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Horario disponible para ayudar:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
            ...timeLabels.entries.map((entry) {
                    final label = entry.key;
                    final hours = entry.value;
                    final isSelected = controller.selectedTimes.contains(label);
                    return CheckboxListTile(
                    title: Text('$label $hours'),
                    value: isSelected,
                    activeColor: Colors.red,
                    onChanged: (bool? value) {
                    setState(() {
                    controller.updateSelectedTimes(label, value ?? false);
                    widget.manager.userData.schedule = controller.selectedTimes.join(', ');
                    widget.manager.saveStep();
                        });
                      },
                    );
                    }).toList(),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.selectedTimes.isNotEmpty) {
                            widget.manager.userData.schedule = controller.selectedTimes.join(', ');
                            widget.manager.saveStep();
                            controller.goToNextScreen(context, widget.manager);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Selecciona al menos un horario antes de continuar.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Siguiente paso', style: TextStyle(color: Colors.white)),
                      ),

                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
